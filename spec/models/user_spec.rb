# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  # == Associations ==
  describe 'associations' do
    it { is_expected.to have_many(:hotels).with_foreign_key(:user_id).dependent(:nullify) }
    it { is_expected.to have_many(:properties).dependent(:nullify) }
    it { is_expected.to have_many(:favorites).dependent(:destroy) }
    it { is_expected.to have_many(:favorite_hotels).through(:favorites).source(:hotel) }
    it { is_expected.to have_many(:bookings).dependent(:destroy) }
    it { is_expected.to have_many(:reviews).dependent(:destroy) }
  end

  # == Validations ==
  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_length_of(:first_name).is_at_most(50) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(50) }

    describe 'email format' do
      it 'accepts valid emails' do
        valid_emails = %w[user@example.com USER@foo.COM first.last@foo.jp alice+bob@baz.cn]
        valid_emails.each do |email|
          subject.email = email
          expect(subject).to be_valid, "#{email} should be valid"
        end
      end

      it 'rejects invalid emails' do
        invalid_emails = %w[user@example,com user_at_foo.org user.name@example.]
        invalid_emails.each do |email|
          subject.email = email
          expect(subject).not_to be_valid, "#{email} should be invalid"
        end
      end
    end

    describe 'phone format' do
      it 'accepts valid phone numbers' do
        valid_phones = ['+7 999 123-45-67', '89991234567', '+1(555)123-4567']
        valid_phones.each do |phone|
          subject.phone = phone
          expect(subject).to be_valid, "#{phone} should be valid"
        end
      end

      it 'rejects invalid phone numbers' do
        subject.phone = 'not-a-phone'
        expect(subject).not_to be_valid
      end

      it 'allows blank phone' do
        subject.phone = nil
        expect(subject).to be_valid
      end
    end
  end

  # == Enums ==
  describe 'enums' do
    it 'defines role enum with correct values' do
      expect(User.roles).to eq({ 'user' => 'user', 'supervisor' => 'supervisor', 'admin' => 'admin' })
    end

    it 'defaults role to user' do
      new_user = User.new
      expect(new_user.role).to eq('user')
    end

    it 'responds to role query methods' do
      expect(build(:user)).to be_user
      expect(build(:user, :supervisor)).to be_supervisor
      expect(build(:user, :admin)).to be_admin
    end
  end

  # == Instance Methods ==
  describe '#full_name' do
    it 'returns first and last name joined' do
      user = build(:user, first_name: 'Иван', last_name: 'Петров')
      expect(user.full_name).to eq('Иван Петров')
    end

    it 'returns first name only when last name is blank' do
      user = build(:user, first_name: 'Иван', last_name: nil)
      expect(user.full_name).to eq('Иван')
    end

    it 'returns email prefix when both names are blank' do
      user = build(:user, first_name: nil, last_name: nil, email: 'test@example.com')
      expect(user.full_name).to eq('test')
    end
  end
end
