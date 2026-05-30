# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Hotels', type: :request do
  let!(:active_hotel) { create(:hotel, :active, name: 'Active Plaza', city: 'Москва') }
  let!(:review_hotel) { create(:hotel, status: 'review', name: 'Review Inn', city: 'Москва') }

  describe 'GET /' do
    it 'returns a successful 200 response' do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it 'includes the active hotels in the page body' do
      get root_path
      expect(response.body).to include('Active Plaza')
      expect(response.body).not_to include('Review Inn')
    end
  end

  describe 'GET /search' do
    it 'finds active hotels by city' do
      get search_hotels_path, params: { city: 'Москва' }
      expect(response.body).to include('Active Plaza')
    end

    it 'returns successful response even for empty searches' do
      get search_hotels_path, params: { city: 'НесуществующийГород' }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Ничего не найдено')
    end

    it 'implements pagination support' do
      # Create 15 more active hotels to trigger pagination (per(12))
      create_list(:hotel, 15, :active, city: 'Москва')
      get search_hotels_path, params: { city: 'Москва' }
      expect(response.body).to include('pagination') # check if pagination element is rendered
    end

    it 'handles valid checkout/checkin date parsing' do
      get search_hotels_path, params: { city: 'Москва', checkin: '2026-06-01', checkout: '2026-06-10' }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /hotels/:id' do
    it 'allows public access to active hotel details' do
      get hotel_path(active_hotel)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Active Plaza')
    end

    it 'raises Pundit NotAuthorizedError or redirects guest from review hotel' do
      get hotel_path(review_hotel)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('У вас нет доступа')
    end

    it 'redirects to root path for invalid hotel ID' do
      get hotel_path(99999)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('не найдена')
    end
  end
end
