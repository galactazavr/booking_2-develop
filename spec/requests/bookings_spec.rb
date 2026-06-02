# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bookings', type: :request do
  let(:user) { create(:user) }
  let(:supervisor) { create(:user, :supervisor) }
  let(:hotel) { create(:hotel, :active, user: supervisor) }
  let(:room) { create(:room, hotel: hotel) }
  let!(:booking) { create(:booking, user: user, room: room, check_in: Date.tomorrow, check_out: Date.tomorrow + 3.days) }

  describe 'GET /bookings' do
    context 'as a guest' do
      it 'redirects to sign in page' do
        get bookings_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'as an authenticated user' do
      before { sign_in user }

      it 'returns a successful 200 response' do
        get bookings_path
        expect(response).to have_http_status(:ok)
      end

      it 'displays user bookings' do
        get bookings_path
        expect(response.body).to include('Мои поездки')
      end
    end
  end

  describe 'GET /bookings/:id' do
    before { sign_in user }

    it 'allows viewing own booking details' do
      get booking_path(booking)
      expect(response).to have_http_status(:ok)
    end

    it 'denies access to others bookings' do
      other_user = create(:user)
      sign_in other_user
      get booking_path(booking)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('У вас нет доступа')
    end
  end

  describe 'POST /bookings' do
    before { sign_in user }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          booking: {
            room_id: room.id,
            check_in: (Date.tomorrow + 5.days).to_s,
            check_out: (Date.tomorrow + 8.days).to_s,
            guests_count: 2
          }
        }
      end

      it 'creates booking and redirects' do
        expect {
          post bookings_path, params: valid_params
        }.to change(Booking, :count).by(1)
        expect(response).to redirect_to(booking_path(Booking.last))
        expect(flash[:notice]).to include('Бронирование успешно создано')
      end
    end

    context 'with overlapping dates (validation failure)' do
      let(:invalid_params) do
        {
          booking: {
            room_id: room.id,
            check_in: booking.check_in.to_s,
            check_out: booking.check_out.to_s,
            guests_count: 2
          }
        }
      end

      it 'does not create booking and returns 422' do
        expect {
          post bookings_path, params: invalid_params
        }.not_to change(Booking, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /bookings/:id/cancel' do
    before { sign_in user }

    it 'cancels active booking and redirects' do
      patch cancel_booking_path(booking)
      expect(response).to redirect_to(bookings_path)
      expect(booking.reload.status).to eq('cancelled')
      expect(flash[:notice]).to include('Бронирование отменено')
    end
  end
end
