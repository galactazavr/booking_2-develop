# frozen_string_literal: true

class Property < ApplicationRecord
  # == Enums ==
  enum :status, { review: 'review', active: 'active', rejected: 'rejected', deleted: 'deleted' }, default: 'review'

  # == Associations ==
  belongs_to :user
  has_many_attached :photos

  # == Validations ==
  validates :name, :property_type, :city, :address, :guests_capacity, presence: true
  validates :rooms_count, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :area, numericality: { greater_than: 0, allow_nil: true }
  validates :guests_capacity, numericality: { greater_than: 0, less_than_or_equal_to: 20 }
  validates :base_price_per_night, presence: true, numericality: { greater_than: 0 }
  validates :available_from, :available_to, presence: true
  validate :available_to_after_available_from

  # == Scopes ==
  scope :by_city, ->(city) { where('city ILIKE ?', "%#{city}%") if city.present? }
  scope :by_type, ->(type) { where(property_type: type) if type.present? }
  scope :available_for_stay, lambda { |checkin, checkout|
    return all if checkin.blank? || checkout.blank?

    where("available_from <= ? AND available_to >= ?", checkin, checkout)
  }

  # == Instance Methods ==
  def display_price
    base_price_per_night || 0
  end

  def full_address
    "#{city}, #{address}"
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

  def available_to_after_available_from
    return if available_from.blank? || available_to.blank?
    return if available_to >= available_from

    errors.add(:available_to, 'должна быть не раньше даты начала доступности')
  end
end
