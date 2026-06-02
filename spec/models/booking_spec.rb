# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Booking, type: :model do
  subject { build(:booking) }

  # == Associations ==
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:room) }
    it { is_expected.to have_one(:hotel).through(:room) }
    it { is_expected.to have_one(:review).dependent(:nullify) }
  end

  # == Validations ==
  describe 'validations' do
    it { is_expected.to validate_presence_of(:check_in) }
    it { is_expected.to validate_presence_of(:check_out) }
    it { is_expected.to validate_presence_of(:guests_count) }
    it { is_expected.to validate_numericality_of(:guests_count).is_greater_than(0).is_less_than_or_equal_to(10) }
    it { is_expected.to validate_numericality_of(:total_price).is_greater_than(0).on(:update) }

    describe 'check_out_after_check_in' do
      it 'rejects check_out on same day as check_in' do
        booking = build(:booking, check_in: Date.tomorrow, check_out: Date.tomorrow)
        expect(booking).not_to be_valid
        expect(booking.errors[:check_out]).to include('должна быть позже даты заезда')
      end

      it 'rejects check_out before check_in' do
        booking = build(:booking, check_in: 3.days.from_now.to_date, check_out: Date.tomorrow)
        expect(booking).not_to be_valid
      end
    end

    describe 'dates_not_in_past' do
      it 'rejects check_in in the past' do
        booking = build(:booking, check_in: 1.day.ago.to_date, check_out: Date.tomorrow)
        expect(booking).not_to be_valid
        expect(booking.errors[:check_in]).to include('не может быть в прошлом')
      end
    end

    describe 'room_capacity_sufficient' do
      it 'rejects guests_count exceeding room capacity' do
        room = create(:room, capacity: 2)
        booking = build(:booking, room: room, guests_count: 5)
        expect(booking).not_to be_valid
        expect(booking.errors[:guests_count].first).to include('превышает вместимость')
      end
    end

    describe 'no_overlapping_bookings' do
      let(:room) { create(:room) }
      let!(:existing) do
        create(:booking, :confirmed,
          room: room,
          check_in: 5.days.from_now.to_date,
          check_out: 10.days.from_now.to_date
        )
      end

      it 'rejects overlapping dates for same room' do
        booking = build(:booking,
          room: room,
          check_in: 7.days.from_now.to_date,
          check_out: 12.days.from_now.to_date
        )
        expect(booking).not_to be_valid
        expect(booking.errors[:base]).to include('Номер уже забронирован на выбранные даты')
      end

      it 'allows non-overlapping dates' do
        booking = build(:booking,
          room: room,
          check_in: 11.days.from_now.to_date,
          check_out: 15.days.from_now.to_date
        )
        expect(booking).to be_valid
      end

      it 'allows overlapping with cancelled bookings' do
        existing.cancelled!

        booking = build(:booking,
          room: room,
          check_in: 7.days.from_now.to_date,
          check_out: 12.days.from_now.to_date
        )
        expect(booking).to be_valid
      end
    end
  end

  # == Enums ==
  describe 'enums' do
    it do
      is_expected.to define_enum_for(:status)
        .with_values(pending: 'pending', confirmed: 'confirmed', cancelled: 'cancelled', completed: 'completed')
        .backed_by_column_of_type(:string)
    end
  end

  # == Callbacks ==
  describe 'callbacks' do
    describe 'calculate_total_price' do
      it 'auto-calculates total_price on create' do
        room = create(:room, price_per_night: 3000)
        booking = build(:booking,
          room: room,
          check_in: Date.tomorrow,
          check_out: 4.days.from_now.to_date,
          total_price: nil
        )
        booking.valid?
        expect(booking.total_price).to eq(3000 * booking.nights_count)
      end
    end
  end

  # == Instance Methods ==
  describe '#nights_count' do
    it 'returns correct number of nights' do
      booking = build(:booking, check_in: Date.tomorrow, check_out: 5.days.from_now.to_date)
      expected = (5.days.from_now.to_date - Date.tomorrow).to_i
      expect(booking.nights_count).to eq(expected)
    end
  end

  describe '#can_cancel?' do
    it 'returns true for pending' do
      expect(build(:booking, status: 'pending').can_cancel?).to be true
    end

    it 'returns true for confirmed' do
      expect(build(:booking, status: 'confirmed').can_cancel?).to be true
    end

    it 'returns false for cancelled' do
      expect(build(:booking, status: 'cancelled').can_cancel?).to be false
    end

    it 'returns false for completed' do
      expect(build(:booking, status: 'completed').can_cancel?).to be false
    end
  end

  describe '#cancel!' do
    it 'cancels a pending booking' do
      booking = create(:booking, status: 'pending')
      expect(booking.cancel!).to be_truthy
      expect(booking.reload).to be_cancelled
    end

    it 'returns false for already cancelled booking' do
      booking = create(:booking, status: 'cancelled')
      expect(booking.cancel!).to be false
    end
  end

  describe '#confirm!' do
    it 'confirms a pending booking' do
      booking = create(:booking, status: 'pending')
      expect(booking.confirm!).to be_truthy
      expect(booking.reload).to be_confirmed
    end

    it 'returns false for non-pending booking' do
      booking = create(:booking, status: 'confirmed')
      expect(booking.confirm!).to be false
    end
  end

  # == Scopes ==
  describe 'scopes' do
    describe '.upcoming' do
      let!(:upcoming) { create(:booking, check_in: 3.days.from_now.to_date, check_out: 7.days.from_now.to_date) }
      let!(:cancelled) { create(:booking, :cancelled, check_in: 3.days.from_now.to_date, check_out: 7.days.from_now.to_date) }

      it 'returns non-cancelled future bookings' do
        expect(Booking.upcoming).to include(upcoming)
        expect(Booking.upcoming).not_to include(cancelled)
      end
    end

    describe '.overlapping' do
      let(:room) { create(:room) }
      let!(:existing) do
        create(:booking, room: room,
          check_in: 5.days.from_now.to_date,
          check_out: 10.days.from_now.to_date,
          status: 'confirmed'
        )
      end

      it 'finds overlapping bookings' do
        result = Booking.overlapping(7.days.from_now.to_date, 12.days.from_now.to_date)
        expect(result).to include(existing)
      end

      it 'excludes non-overlapping bookings' do
        result = Booking.overlapping(11.days.from_now.to_date, 15.days.from_now.to_date)
        expect(result).not_to include(existing)
      end
    end
  end
end
