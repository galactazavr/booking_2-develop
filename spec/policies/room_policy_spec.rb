# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomPolicy, type: :policy do
  let(:regular_user) { create(:user) }
  let(:supervisor) { create(:user, :supervisor) }
  let(:other_supervisor) { create(:user, :supervisor) }
  let(:admin) { create(:user, :admin) }
  
  let(:hotel) { create(:hotel, :active, user: supervisor) }
  let(:room) { create(:room, hotel: hotel) }

  describe 'permissions' do
    context 'as a guest (nil user)' do
      let(:policy) { described_class.new(nil, room) }

      it { expect(policy.show?).to be true }
      it { expect(policy.create?).to be false }
      it { expect(policy.update?).to be false }
      it { expect(policy.destroy?).to be false }
    end

    context 'as a regular user' do
      let(:policy) { described_class.new(regular_user, room) }

      it { expect(policy.show?).to be true }
      it { expect(policy.create?).to be false }
      it { expect(policy.update?).to be false }
      it { expect(policy.destroy?).to be false }
    end

    context 'as the hotel supervisor' do
      let(:policy) { described_class.new(supervisor, room) }

      it { expect(policy.create?).to be true }
      it { expect(policy.update?).to be true }
      it { expect(policy.destroy?).to be true }
    end

    context 'as another supervisor' do
      let(:policy) { described_class.new(other_supervisor, room) }

      it { expect(policy.create?).to be false }
      it { expect(policy.update?).to be false }
      it { expect(policy.destroy?).to be false }
    end

    context 'as admin' do
      let(:policy) { described_class.new(admin, room) }

      it { expect(policy.update?).to be true }
      it { expect(policy.destroy?).to be true }
    end
  end
end
