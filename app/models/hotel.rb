# frozen_string_literal: true

class Hotel < ApplicationRecord
  # == Enums ==
  enum :status, { review: 'review', active: 'active', rejected: 'rejected', deleted: 'deleted' }, default: 'review'

  # == Associations ==
  belongs_to :user, optional: true
  has_many :rooms, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :bookings, through: :rooms
  has_many_attached :photos

  # == Validations ==
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :hotel_type, presence: true, inclusion: {
    in: %w[Отель База\ отдыха Апарт-отель Гостевой\ дом Хостел Санаторий Глэмпинг Другое]
  }
  validates :city, :address, presence: true
  validates :base_price_per_night, presence: true, numericality: { greater_than: 0 }, if: :managed_by_supervisor?
  validates :available_from, :available_to, presence: true, if: :managed_by_supervisor?
  validates :phone, length: { maximum: 20 }, allow_blank: true
  validates :email, length: { maximum: 100 }, allow_blank: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true
  validate :available_to_after_available_from

  # == Scopes ==
  scope :by_city, ->(city) { where('city ILIKE ?', "%#{city}%") if city.present? }
  scope :by_type, ->(type) { where(hotel_type: type) if type.present? }
  scope :with_available_rooms, -> { joins(:rooms).where(rooms: { available: true }).distinct }
  scope :available_for_stay, lambda { |checkin, checkout|
    return all if checkin.blank? || checkout.blank?

    where("available_from <= ? AND available_to >= ?", checkin, checkout)
  }

  # == Instance Methods ==
  def full_address
    "#{city}, #{address}"
  end

  def average_rating
    return rating if rating.present?

    calculated = reviews.average(:rating)
    calculated&.round(1) || 0
  end

  def display_price
    base_price_per_night.presence || rooms.minimum(:price_per_night) || 0
  end

  def availability_label
    return 'Даты по запросу' if available_from.blank? || available_to.blank?

    "#{I18n.l(available_from, format: '%d %b')} — #{I18n.l(available_to, format: '%d %b')}"
  end

  def status_label
    case status
    when 'review' then 'На модерации'
    when 'active' then 'Активен'
    when 'rejected' then 'Отклонён'
    else status
    end
  end

  private

  def managed_by_supervisor?
    user_id.present? || user.present?
  end

  def available_to_after_available_from
    return if available_from.blank? || available_to.blank?
    return if available_to >= available_from

    errors.add(:available_to, 'должна быть не раньше даты начала доступности')
  end
end
