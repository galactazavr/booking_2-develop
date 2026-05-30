# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HotelPolicy, type: :policy do
  let(:regular_user) { create(:user) }
  let(:supervisor) { create(:user, :supervisor) }
  let(:other_supervisor) { create(:user, :supervisor) }
  let(:admin) { create(:user, :admin) }
  let(:hotel) { create(:hotel, :active, user: supervisor) }

  describe 'permissions' do
    context 'as a guest (nil user)' do
      let(:policy) { described_class.new(nil, hotel) }

      it { expect(policy.index?).to be true }
      it { expect(policy.show?).to be true }
      it { expect(policy.create?).to be false }
      it { expect(policy.update?).to be false }
      it { expect(policy.destroy?).to be false }
    end

    context 'as a regular user' do
      let(:policy) { described_class.new(regular_user, hotel) }

      it { expect(policy.index?).to be true }
      it { expect(policy.show?).to be true }
      it { expect(policy.create?).to be false }
      it { expect(policy.update?).to be false }
    end

    context 'as the owning supervisor' do
      let(:policy) { described_class.new(supervisor, hotel) }

      it { expect(policy.create?).to be true }
      it { expect(policy.update?).to be true }
      it { expect(policy.destroy?).to be true }
    end

    context 'as another supervisor' do
      let(:policy) { described_class.new(other_supervisor, hotel) }

      it { expect(policy.update?).to be false }
      it { expect(policy.destroy?).to be false }
    end

    context 'as admin' do
      let(:policy) { described_class.new(admin, hotel) }

      it { expect(policy.update?).to be true }
      it { expect(policy.destroy?).to be true }
    end
  end

  describe 'show? for non-active hotel' do
    let(:review_hotel) { create(:hotel, user: supervisor, status: 'review') }

    it 'denies guest access to review hotel' do
      policy = described_class.new(nil, review_hotel)
      expect(policy.show?).to be false
    end

    it 'allows owner to see review hotel' do
      policy = described_class.new(supervisor, review_hotel)
      expect(policy.show?).to be true
    end
  end
end
