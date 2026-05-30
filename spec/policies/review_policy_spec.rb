# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReviewPolicy, type: :policy do
  let(:author) { create(:user) }
  let(:other_user) { create(:user) }
  let(:supervisor) { create(:user, :supervisor) }
  let(:admin) { create(:user, :admin) }
  
  let(:hotel) { create(:hotel, :active) }
  let(:review) { create(:review, user: author, hotel: hotel) }

  describe 'permissions' do
    context 'as a guest (nil user)' do
      let(:policy) { described_class.new(nil, review) }

      it { expect(policy.create?).to be false }
      it { expect(policy.destroy?).to be false }
    end

    context 'as a regular user (not the author)' do
      let(:policy) { described_class.new(other_user, review) }

      it { expect(policy.create?).to be true }
      it { expect(policy.destroy?).to be false }
    end

    context 'as the author of the review' do
      let(:policy) { described_class.new(author, review) }

      it { expect(policy.create?).to be true }
      it { expect(policy.destroy?).to be true }
    end

    context 'as a supervisor' do
      let(:policy) { described_class.new(supervisor, review) }

      it { expect(policy.create?).to be false }
      it { expect(policy.destroy?).to be false }
    end

    context 'as admin' do
      let(:policy) { described_class.new(admin, review) }

      it { expect(policy.create?).to be false }
      it { expect(policy.destroy?).to be true }
    end
  end
end
