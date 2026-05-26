# frozen_string_literal: true

class Room < ApplicationRecord
  # == Associations ==
  belongs_to :hotel
  has_many :bookings, dependent: :restrict_with_error
  has_many_attached :photos

  # == Constants ==
  ROOM_TYPES = %w[Стандарт Люкс Семейный Эконом Студия Президентский].freeze

  # == Validations ==
  validates :name, :room_type, presence: true
  validates :room_type, inclusion: { in: ROOM_TYPES }
  validates :capacity, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 10 }
  validates :area, presence: true, numericality: { greater_than: 0 }
  validates :price_per_night, presence: true, numericality: { greater_than: 0 }

  # == Scopes ==
  scope :available, -> { where(available: true) }
  scope :by_type, ->(type) { where(room_type: type) if type.present? }
  scope :by_capacity, ->(capacity) { where('capacity >= ?', capacity) if capacity.present? }
  scope :by_price_range, ->(min, max) { where(price_per_night: min..max) if min.present? && max.present? }

  # == Instance Methods ==
  def formatted_price
    "#{price_per_night.to_i} ₽/ночь"
  end

  def short_info
    "#{name} (#{room_type}, до #{capacity} чел.)"
  end

  def available_for_dates?(check_in, check_out)
    return false unless available?

    bookings
      .where.not(status: 'cancelled')
      .where('check_in < ? AND check_out > ?', check_out, check_in)
      .none?
  end
end
