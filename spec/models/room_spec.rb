# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Room, type: :model do
  subject { build(:room) }

  # == Associations ==
  describe 'associations' do
    it { is_expected.to belong_to(:hotel) }
    it { is_expected.to have_many(:bookings).dependent(:restrict_with_error) }
  end

  # == Validations ==
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:room_type) }
    it { is_expected.to validate_presence_of(:capacity) }
    it { is_expected.to validate_numericality_of(:capacity).is_greater_than(0).is_less_than_or_equal_to(10) }
    it { is_expected.to validate_presence_of(:area) }
    it { is_expected.to validate_numericality_of(:area).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:price_per_night) }
    it { is_expected.to validate_numericality_of(:price_per_night).is_greater_than(0) }

    it 'validates room_type inclusion' do
      subject.room_type = 'Несуществующий'
      expect(subject).not_to be_valid
    end
  end

  # == Instance Methods ==
  describe '#formatted_price' do
    it 'formats price with currency symbol' do
      room = build(:room, price_per_night: 3500.0)
      expect(room.formatted_price).to eq('3500 ₽/ночь')
    end
  end

  describe '#short_info' do
    it 'returns compact description' do
      room = build(:room, name: 'Делюкс 301', room_type: 'Люкс', capacity: 2)
      expect(room.short_info).to eq('Делюкс 301 (Люкс, до 2 чел.)')
    end
  end

  describe '#available_for_dates?' do
    let(:hotel) { create(:hotel) }
    let(:room) { create(:room, hotel: hotel, available: true) }

    it 'returns true when no conflicting bookings' do
      expect(room.available_for_dates?(Date.tomorrow, 3.days.from_now.to_date)).to be true
    end

    it 'returns false when there is an overlapping booking' do
      create(:booking,
        room: room,
        check_in: Date.tomorrow,
        check_out: 5.days.from_now.to_date,
        status: 'confirmed'
      )

      expect(room.available_for_dates?(3.days.from_now.to_date, 7.days.from_now.to_date)).to be false
    end

    it 'returns true when overlapping booking is cancelled' do
      create(:booking,
        room: room,
        check_in: Date.tomorrow,
        check_out: 5.days.from_now.to_date,
        status: 'cancelled'
      )

      expect(room.available_for_dates?(3.days.from_now.to_date, 7.days.from_now.to_date)).to be true
    end

    it 'returns false when room is unavailable' do
      room.update!(available: false)
      expect(room.available_for_dates?(Date.tomorrow, 3.days.from_now.to_date)).to be false
    end
  end
end
