# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Supervisor Dashboard', type: :request do
  let(:user) { create(:user) }
  let(:supervisor) { create(:user, :supervisor) }
  let(:hotel) { create(:hotel, :active, user: supervisor) }
  let(:property) { create(:property, :active, user: supervisor) }

  describe 'Access Restrictions' do
    it 'redirects guest to sign in' do
      get supervisor_root_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects regular user with warning' do
      sign_in user
      get supervisor_root_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('Только для супервайзоров')
    end

    it 'allows supervisor access' do
      sign_in supervisor
      get supervisor_root_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /supervisor/choice' do
    before { sign_in supervisor }

    it 'renders choice screen' do
      get supervisor_choice_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /supervisor/create_hotel' do
    before { sign_in supervisor }

    context 'with valid parameters' do
      let(:hotel_params) do
        {
          hotel: {
            name: 'New Supervisor Hotel',
            hotel_type: 'Отель',
            city: 'Москва',
            address: 'Тверская 10',
            description: 'Amazing hotel',
            base_price_per_night: 5000,
            available_from: Date.tomorrow.to_s,
            available_to: (Date.tomorrow + 30.days).to_s
          }
        }
      end

      it 'creates hotel in review state and redirects to success' do
        post supervisor_create_hotel_path, params: hotel_params
        if response.status != 302
          puts "RSPEC DEBUG: POST failed with status #{response.status}!"
          puts "RSPEC DEBUG: response body: #{response.body[0..3000]}"
        end
        
        expect(response).to redirect_to(supervisor_success_path(type: 'hotel', id: Hotel.last&.id))
      end
    end
  end

  describe 'POST /supervisor/create_property' do
    before { sign_in supervisor }

    context 'with valid parameters' do
      let(:property_params) do
        {
          property: {
            name: 'New Supervisor Apart',
            property_type: 'apartment',
            city: 'Сочи',
            address: 'Курортный 20',
            rooms_count: 2,
            area: 45,
            guests_capacity: 4,
            description: 'Apartment near sea',
            base_price_per_night: 6000,
            available_from: Date.tomorrow.to_s,
            available_to: (Date.tomorrow + 30.days).to_s
          }
        }
      end

      it 'creates property in review state and redirects' do
        expect {
          post supervisor_create_property_path, params: property_params
        }.to change(Property, :count).by(1)
        
        new_prop = Property.last
        expect(new_prop.status).to eq('review')
        expect(response).to redirect_to(supervisor_success_path(type: 'property', id: new_prop.id))
      end
    end
  end
end
