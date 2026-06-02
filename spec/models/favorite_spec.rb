# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Favorite, type: :model do
  subject { build(:favorite) }

  # == Associations ==
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:hotel) }
  end

  # == Validations ==
  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:hotel_id) }

    it 'prevents duplicate favorites' do
      user = create(:user)
      hotel = create(:hotel)
      create(:favorite, user: user, hotel: hotel)
      duplicate = build(:favorite, user: user, hotel: hotel)
      expect(duplicate).not_to be_valid
    end

    it 'allows same user to favorite different hotels' do
      user = create(:user)
      create(:favorite, user: user, hotel: create(:hotel))
      another = build(:favorite, user: user, hotel: create(:hotel))
      expect(another).to be_valid
    end
  end
end
