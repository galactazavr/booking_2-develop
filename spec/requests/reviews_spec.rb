# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reviews', type: :request do
  let(:user) { create(:user) }
  let(:hotel) { create(:hotel, :active) }
  let(:room) { create(:room, hotel: hotel) }
  let!(:booking) { create(:booking, user: user, room: room, status: 'completed', check_in: 5.days.ago, check_out: 2.days.ago) }

  describe 'POST /hotels/:hotel_id/reviews' do
    context 'as guest' do
      it 'redirects to sign in' do
        post hotel_reviews_path(hotel), params: { review: { rating: 5, body: 'Great!' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'as authenticated user' do
      before { sign_in user }

      it 'creates a review with valid params' do
        expect {
          post hotel_reviews_path(hotel), params: { review: { rating: 5, body: 'Отличный отель!' } }
        }.to change(Review, :count).by(1)
        expect(response).to redirect_to(hotel_path(hotel))
        expect(flash[:notice]).to include('Отзыв успешно добавлен')
      end

      it 'rejects review with invalid rating' do
        expect {
          post hotel_reviews_path(hotel), params: { review: { rating: 0, body: 'Bad' } }
        }.not_to change(Review, :count)
        expect(response).to redirect_to(hotel_path(hotel))
        expect(flash[:alert]).to be_present
      end

      it 'rejects review without rating' do
        expect {
          post hotel_reviews_path(hotel), params: { review: { rating: nil, body: 'No rating' } }
        }.not_to change(Review, :count)
      end
    end

    context 'as supervisor' do
      let(:supervisor) { create(:user, :supervisor) }

      it 'denies creating review (only users can review)' do
        sign_in supervisor
        post hotel_reviews_path(hotel), params: { review: { rating: 5, body: 'Test' } }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include('У вас нет доступа')
      end
    end
  end

  describe 'DELETE /hotels/:hotel_id/reviews/:id' do
    let!(:review) { create(:review, user: user, hotel: hotel) }

    context 'as review owner' do
      before { sign_in user }

      it 'deletes own review' do
        expect {
          delete hotel_review_path(hotel, review)
        }.to change(Review, :count).by(-1)
        expect(response).to redirect_to(hotel_path(hotel))
      end
    end

    context 'as another user' do
      let(:other_user) { create(:user) }
      before { sign_in other_user }

      it 'denies deleting others review' do
        delete hotel_review_path(hotel, review)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include('У вас нет доступа')
      end
    end

    context 'as admin' do
      let(:admin) { create(:user, :admin) }
      before { sign_in admin }

      it 'allows admin to delete any review' do
        expect {
          delete hotel_review_path(hotel, review)
        }.to change(Review, :count).by(-1)
      end
    end
  end
end
