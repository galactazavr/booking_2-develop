# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Property, type: :model do
  subject { build(:property) }

  # == Associations ==
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  # == Validations ==
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:property_type) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:guests_capacity) }
    it { is_expected.to validate_numericality_of(:guests_capacity).is_greater_than(0).is_less_than_or_equal_to(20) }
    it { is_expected.to validate_presence_of(:base_price_per_night) }
    it { is_expected.to validate_numericality_of(:base_price_per_night).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:available_from) }
    it { is_expected.to validate_presence_of(:available_to) }

    describe 'date range validation' do
      it 'rejects available_to before available_from' do
        prop = build(:property, available_from: Date.tomorrow, available_to: Date.today)
        expect(prop).not_to be_valid
        expect(prop.errors[:available_to]).to be_present
      end
    end
  end

  # == Enums ==
  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(review: 'review', active: 'active', rejected: 'rejected').backed_by_column_of_type(:string) }
  end

  # == Scopes ==
  describe 'scopes' do
    describe '.by_city' do
      let!(:spb_prop) { create(:property, :active, city: 'Санкт-Петербург') }
      let!(:msk_prop) { create(:property, :active, city: 'Москва') }

      it 'filters by city' do
        expect(Property.by_city('Петербург')).to include(spb_prop)
        expect(Property.by_city('Петербург')).not_to include(msk_prop)
      end
    end
  end

  # == Instance Methods ==
  describe '#full_address' do
    it 'combines city and address' do
      prop = build(:property, city: 'Сочи', address: 'ул. Курортная, 10')
      expect(prop.full_address).to eq('Сочи, ул. Курортная, 10')
    end
  end

  describe '#display_price' do
    it 'returns base price' do
      prop = build(:property, base_price_per_night: 4000)
      expect(prop.display_price).to eq(4000)
    end

    it 'returns 0 when no price' do
      prop = build(:property)
      prop.base_price_per_night = nil
      expect(prop.display_price).to eq(0)
    end
  end
end
