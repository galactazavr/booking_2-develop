# frozen_string_literal: true

class Review < ApplicationRecord
  # == Associations ==
  belongs_to :user
  belongs_to :hotel
  belongs_to :booking, optional: true

  # == Validations ==
  validates :rating, presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :body, length: { maximum: 2000 }, allow_blank: true
  validates :user_id, uniqueness: { scope: :booking_id, message: 'уже оставил отзыв на это бронирование' }, unless: -> { booking_id.nil? }
  validate :booking_must_be_completed_and_belong_to_user

  # == Scopes ==
  scope :recent, -> { order(created_at: :desc) }
  scope :with_text, -> { where.not(body: [nil, '']) }

  # == Instance Methods ==
  def author_name
    user.full_name
  end

  def stars
    '★' * rating + '☆' * (5 - rating)
  end

  private

  def booking_must_be_completed_and_belong_to_user
    return unless booking.present?

    if booking.user_id != user_id
      errors.add(:booking, 'должно принадлежать автору отзыва')
    end
    if booking.status != 'completed'
      errors.add(:booking, 'должно иметь статус завершено')
    end
    if booking.room.hotel_id != hotel_id
      errors.add(:booking, 'должно относиться к выбранному отелю')
    end
  end
end
