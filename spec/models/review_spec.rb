# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Review, type: :model do
  subject { build(:review) }

  # == Associations ==
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:hotel) }
    it { is_expected.to belong_to(:booking).optional }
  end

  # == Validations ==
  describe 'validations' do
    it { is_expected.to validate_presence_of(:rating) }
    it { is_expected.to validate_numericality_of(:rating).only_integer.is_greater_than_or_equal_to(1).is_less_than_or_equal_to(5) }
    it { is_expected.to validate_length_of(:body).is_at_most(2000) }

    describe 'uniqueness per user and booking' do
      let(:user) { create(:user) }
      let(:hotel) { create(:hotel) }
      let(:room) { create(:room, hotel: hotel) }
      let(:booking) do
        b = build(:booking, user: user, room: room, status: 'completed', check_in: 5.days.ago, check_out: 2.days.ago)
        b.save!(validate: false)
        b
      end

      it 'prevents duplicate reviews for the same booking' do
        create(:review, user: user, hotel: hotel, booking: booking)
        duplicate = build(:review, user: user, hotel: hotel, booking: booking)
        expect(duplicate).not_to be_valid
      end

      it 'allows reviews without booking_id' do
        create(:review, user: user, hotel: hotel, booking: nil)
        another = build(:review, user: user, hotel: hotel, booking: nil)
        expect(another).to be_valid
      end
    end
  end

  # == Instance Methods ==
  describe '#stars' do
    it 'returns correct star string for rating 4' do
      review = build(:review, rating: 4)
      expect(review.stars).to eq('★★★★☆')
    end

    it 'returns all stars for rating 5' do
      review = build(:review, rating: 5)
      expect(review.stars).to eq('★★★★★')
    end

    it 'returns one star for rating 1' do
      review = build(:review, rating: 1)
      expect(review.stars).to eq('★☆☆☆☆')
    end
  end

  describe '#author_name' do
    it 'returns user full name' do
      user = build(:user, first_name: 'Анна', last_name: 'Иванова')
      review = build(:review, user: user)
      expect(review.author_name).to eq('Анна Иванова')
    end
  end
end
