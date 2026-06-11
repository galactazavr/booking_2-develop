# frozen_string_literal: true

class Booking < ApplicationRecord
  # == Enums ==
  enum :status, {
    pending: 'pending',
    confirmed: 'confirmed',
    cancelled: 'cancelled',
    completed: 'completed'
  }, default: 'pending'

  # == Associations ==
  belongs_to :user
  belongs_to :room
  has_one :hotel, through: :room
  has_one :review, dependent: :nullify
  has_many :notifications, dependent: :destroy

  # == Callbacks ==
  before_validation :calculate_total_price, on: :create
  after_create_commit :notify_booking_created
  after_update_commit :notify_booking_status_change

  # == Validations ==
  validates :check_in, :check_out, :guests_count, :total_price, presence: true
  validates :guest_name, :guest_phone, :guest_passport, presence: true, on: :create
  validates :guests_count, numericality: { greater_than: 0, less_than_or_equal_to: 10 }
  validates :total_price, numericality: { greater_than: 0 }
  validate :check_out_after_check_in
  validate :dates_not_in_past, on: :create
  validate :room_capacity_sufficient
  validate :no_overlapping_bookings, on: :create

  # == Scopes ==
  scope :upcoming, -> { where('check_in >= ?', Date.today).where.not(status: 'cancelled') }
  scope :past, -> { where('check_out < ?', Date.today) }
  scope :active, -> { where(status: %w[pending confirmed]) }
  scope :for_room, ->(room_id) { where(room_id: room_id) }
  scope :overlapping, ->(check_in, check_out) {
    where('check_in < ? AND check_out > ?', check_out, check_in)
      .where.not(status: 'cancelled')
  }

  # == Instance Methods ==
  def nights_count
    return 0 if check_in.blank? || check_out.blank?

    (check_out - check_in).to_i
  end

  def can_cancel?
    pending? || confirmed?
  end

  def cancel!(reason = nil)
    return false unless can_cancel?

    self.cancellation_reason = reason if reason.present?
    cancelled!
  end

  def confirm!
    return false unless pending?

    confirmed!
  end

  def complete!
    return false unless confirmed?

    completed!
  end

  def price_per_night
    room&.price_per_night || 0
  end

  def status_label
    I18n.t("enums.booking.status.#{status}", default: status.humanize)
  end

  def date_range_label
    return '' if check_in.blank? || check_out.blank?

    "#{I18n.l(check_in, format: '%d %b %Y')} — #{I18n.l(check_out, format: '%d %b %Y')}"
  end

  private

  def calculate_total_price
    return if room.blank? || check_in.blank? || check_out.blank?
    return if total_price.present? && total_price > 0

    self.total_price = nights_count * room.price_per_night
  end

  def check_out_after_check_in
    return if check_in.blank? || check_out.blank?
    return if check_out > check_in

    errors.add(:check_out, 'должна быть позже даты заезда')
  end

  def dates_not_in_past
    return if check_in.blank?
    return if completed?

    if check_in < Date.today
      errors.add(:check_in, 'не может быть в прошлом')
    end
  end

  def room_capacity_sufficient
    return if room.blank? || guests_count.blank?
    return if guests_count <= room.capacity

    errors.add(:guests_count, "превышает вместимость номера (максимум: #{room.capacity})")
  end

  def no_overlapping_bookings
    return if room.blank? || check_in.blank? || check_out.blank?

    overlapping = Booking.for_room(room_id)
                         .overlapping(check_in, check_out)
    overlapping = overlapping.where.not(id: id) if persisted?

    if overlapping.exists?
      errors.add(:base, 'Номер уже забронирован на выбранные даты')
    end
  end

  # -- Notifications via Sidekiq --

  def notify_booking_created
    BookingNotificationJob.perform_later(id, 'created')
  end

  def notify_booking_status_change
    return unless saved_change_to_status?

    case status
    when 'confirmed'
      BookingNotificationJob.perform_later(id, 'confirmed')
    when 'cancelled'
      BookingNotificationJob.perform_later(id, 'cancelled')
    end
  end

  def self.update_completed_bookings!
    where(status: 'confirmed').where('check_out < ?', Date.today).find_each do |booking|
      if booking.update(status: 'completed')
        BookingNotificationJob.perform_later(booking.id, 'completed')
      end
    end
  end
end
