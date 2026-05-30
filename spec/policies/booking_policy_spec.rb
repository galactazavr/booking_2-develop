# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookingPolicy, type: :policy do
  let(:regular_user) { create(:user) }
  let(:supervisor) { create(:user, :supervisor) }
  let(:admin) { create(:user, :admin) }
  let(:hotel) { create(:hotel, user: supervisor) }
  let(:room) { create(:room, hotel: hotel) }
  let(:booking) { create(:booking, user: regular_user, room: room) }

  describe 'permissions' do
    context 'as a regular user' do
      let(:policy) { described_class.new(regular_user, booking) }

      it { expect(policy.index?).to be true }
      it { expect(policy.show?).to be true }
      it { expect(policy.create?).to be true }

      it 'allows cancelling own pending booking' do
        expect(policy.cancel?).to be true
      end

      it 'denies confirming' do
        expect(policy.confirm?).to be false
      end
    end

    context 'as the hotel supervisor' do
      let(:policy) { described_class.new(supervisor, booking) }

      it { expect(policy.show?).to be true }
      it { expect(policy.create?).to be false }

      it 'allows confirming pending bookings' do
        expect(policy.confirm?).to be true
      end
    end

    context 'as another user' do
      let(:other_user) { create(:user) }
      let(:policy) { described_class.new(other_user, booking) }

      it { expect(policy.show?).to be false }
      it { expect(policy.cancel?).to be false }
    end

    context 'as admin' do
      let(:policy) { described_class.new(admin, booking) }

      it { expect(policy.show?).to be true }
      it { expect(policy.confirm?).to be true }
    end
  end

  describe 'scope' do
    let!(:user_booking) { create(:booking, user: regular_user, room: room) }
    let!(:other_booking) { create(:booking, room: create(:room, hotel: create(:hotel)),
                                  check_in: 15.days.from_now.to_date,
                                  check_out: 20.days.from_now.to_date) }

    it 'returns own bookings for regular user' do
      scope = Pundit.policy_scope(regular_user, Booking)
      expect(scope).to include(user_booking)
      expect(scope).not_to include(other_booking)
    end

    it 'returns hotel bookings for supervisor' do
      scope = Pundit.policy_scope(supervisor, Booking)
      expect(scope).to include(user_booking)
    end

    it 'returns all bookings for admin' do
      scope = Pundit.policy_scope(admin, Booking)
      expect(scope).to include(user_booking, other_booking)
    end
  end
end
