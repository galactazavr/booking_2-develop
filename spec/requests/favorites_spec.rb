# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Favorites', type: :request do
  let(:user) { create(:user) }
  let!(:hotel) { create(:hotel, :active) }

  describe 'GET /favorites' do
    context 'as guest' do
      it 'redirects to sign in' do
        get favorites_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'as authenticated user' do
      before { sign_in user }

      it 'returns 200' do
        get favorites_path
        expect(response).to have_http_status(:ok)
      end

      it 'shows favorited hotels' do
        create(:favorite, user: user, hotel: hotel)
        get favorites_path
        expect(response.body).to include(hotel.name)
      end
    end
  end

  describe 'POST /favorites/toggle/:hotel_id' do
    before { sign_in user }

    it 'adds hotel to favorites' do
      expect {
        post toggle_favorites_path(hotel_id: hotel.id)
      }.to change(Favorite, :count).by(1)
      expect(response).to redirect_to(root_path).or redirect_to(hotel_path(hotel))
    end

    it 'removes hotel from favorites if already favorited' do
      create(:favorite, user: user, hotel: hotel)
      expect {
        post toggle_favorites_path(hotel_id: hotel.id)
      }.to change(Favorite, :count).by(-1)
    end
  end
end
