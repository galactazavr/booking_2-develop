# frozen_string_literal: true

class User < ApplicationRecord
  # == Devise Modules ==
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # == Enums ==
  enum :role, { user: 'user', supervisor: 'supervisor', admin: 'admin' }, default: 'user'

  # == Associations ==
  has_many :hotels, foreign_key: :user_id, dependent: :nullify
  has_many :properties, dependent: :nullify
  has_many :favorites, dependent: :destroy
  has_many :favorite_hotels, through: :favorites, source: :hotel
  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :notifications, dependent: :destroy

  # == Validations ==
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_PHONE_REGEX = /\A\+?[\d\s\-()]{7,20}\z/

  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: VALID_EMAIL_REGEX, message: 'некорректный формат email' }

  validates :first_name, length: { maximum: 50 }, allow_blank: true
  validates :last_name, length: { maximum: 50 }, allow_blank: true
  validates :phone,
    format: { with: VALID_PHONE_REGEX, message: 'некорректный формат телефона' },
    allow_blank: true

  # == Instance Methods ==
  def full_name
    [first_name, last_name].compact_blank.join(' ').presence || email.split('@').first
  end

  def display_role
    I18n.t("enums.user.role.#{role}", default: role.humanize)
  end
end
