class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :booking, optional: true

  validates :title, :message, presence: true

  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }
end
