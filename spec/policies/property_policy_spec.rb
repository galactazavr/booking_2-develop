# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PropertyPolicy, type: :policy do
  let(:regular_user) { create(:user) }
  let(:supervisor) { create(:user, :supervisor) }
  let(:other_supervisor) { create(:user, :supervisor) }
  let(:admin) { create(:user, :admin) }
  let(:property) { create(:property, :active, user: supervisor) }

  describe 'permissions' do
    context 'as a guest (nil user)' do
      let(:policy) { described_class.new(nil, property) }

      it { expect(policy.index?).to be true }
      it { expect(policy.show?).to be true }
      it { expect(policy.create?).to be false }
      it { expect(policy.update?).to be false }
      it { expect(policy.destroy?).to be false }
    end

    context 'as a regular user' do
      let(:policy) { described_class.new(regular_user, property) }

      it { expect(policy.index?).to be true }
      it { expect(policy.show?).to be true }
      it { expect(policy.create?).to be false }
      it { expect(policy.update?).to be false }
      it { expect(policy.destroy?).to be false }
    end

    context 'as the owning supervisor' do
      let(:policy) { described_class.new(supervisor, property) }

      it { expect(policy.create?).to be true }
      it { expect(policy.update?).to be true }
      it { expect(policy.destroy?).to be true }
    end

    context 'as another supervisor' do
      let(:policy) { described_class.new(other_supervisor, property) }

      it { expect(policy.update?).to be false }
      it { expect(policy.destroy?).to be false }
    end

    context 'as admin' do
      let(:policy) { described_class.new(admin, property) }

      it { expect(policy.update?).to be true }
      it { expect(policy.destroy?).to be true }
    end
  end

  describe 'show? for non-active property' do
    let(:review_property) { create(:property, user: supervisor, status: 'review') }

    it 'denies guest access to review property' do
      policy = described_class.new(nil, review_property)
      expect(policy.show?).to be false
    end

    it 'allows owner to see review property' do
      policy = described_class.new(supervisor, review_property)
      expect(policy.show?).to be true
    end
  end
end
