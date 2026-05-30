# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hotel, type: :model do
  subject { build(:hotel) }

  # == Associations ==
  describe 'associations' do
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to have_many(:rooms).dependent(:destroy) }
    it { is_expected.to have_many(:favorites).dependent(:destroy) }
    it { is_expected.to have_many(:reviews).dependent(:destroy) }
    it { is_expected.to have_many(:bookings).through(:rooms) }
  end

  # == Validations ==
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(100) }
    it { is_expected.to validate_presence_of(:hotel_type) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:address) }

    it 'validates hotel_type inclusion' do
      subject.hotel_type = 'Неизвестный тип'
      expect(subject).not_to be_valid
      expect(subject.errors[:hotel_type]).to be_present
    end

    context 'when managed by supervisor' do
      let(:hotel) { build(:hotel, :with_supervisor) }

      it 'requires base price and availability dates' do
        hotel.base_price_per_night = nil
        hotel.available_from = nil
        hotel.available_to = nil
        expect(hotel).not_to be_valid
        expect(hotel.errors[:base_price_per_night]).to be_present
        expect(hotel.errors[:available_from]).to be_present
        expect(hotel.errors[:available_to]).to be_present
      end
    end

    context 'when not managed by supervisor' do
      subject { build(:hotel, user: nil) }

      it 'does not require price' do
        subject.base_price_per_night = nil
        expect(subject).to be_valid
      end
    end

    describe 'date range validation' do
      it 'rejects available_to before available_from' do
        hotel = build(:hotel, available_from: Date.tomorrow, available_to: Date.today)
        expect(hotel).not_to be_valid
        expect(hotel.errors[:available_to]).to be_present
      end

      it 'accepts same dates' do
        hotel = build(:hotel, available_from: Date.today, available_to: Date.today)
        expect(hotel).to be_valid
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
      let!(:moscow_hotel) { create(:hotel, :active, city: 'Москва') }
      let!(:spb_hotel) { create(:hotel, :active, city: 'Санкт-Петербург') }

      it 'filters by city (case-insensitive)' do
        expect(Hotel.by_city('москва')).to include(moscow_hotel)
        expect(Hotel.by_city('москва')).not_to include(spb_hotel)
      end

      it 'returns all when city is blank' do
        expect(Hotel.by_city(nil)).to include(moscow_hotel, spb_hotel)
      end
    end

    describe '.available_for_stay' do
      let!(:available) { create(:hotel, :active, available_from: Date.today, available_to: 1.month.from_now.to_date) }
      let!(:unavailable) { create(:hotel, :active, available_from: 3.months.ago.to_date, available_to: 2.months.ago.to_date) }

      it 'returns hotels available for given dates' do
        result = Hotel.available_for_stay(Date.today, 1.week.from_now.to_date)
        expect(result).to include(available)
        expect(result).not_to include(unavailable)
      end
    end
  end

  # == Instance Methods ==
  describe '#full_address' do
    it 'combines city and address' do
      hotel = build(:hotel, city: 'Москва', address: 'ул. Тверская, 1')
      expect(hotel.full_address).to eq('Москва, ул. Тверская, 1')
    end
  end

  describe '#display_price' do
    it 'returns base_price_per_night when present' do
      hotel = build(:hotel, base_price_per_night: 5000)
      expect(hotel.display_price).to eq(5000)
    end

    it 'returns minimum room price when base price is absent' do
      hotel = create(:hotel, base_price_per_night: nil)
      create(:room, hotel: hotel, price_per_night: 3000)
      create(:room, hotel: hotel, price_per_night: 5000)
      expect(hotel.display_price).to eq(3000)
    end

    it 'returns 0 when no prices exist' do
      hotel = create(:hotel, base_price_per_night: nil)
      expect(hotel.display_price).to eq(0)
    end
  end
end
