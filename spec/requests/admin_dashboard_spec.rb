# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Dashboard', type: :request do
  let(:regular_user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:supervisor) { create(:user, :supervisor) }
  
  let!(:hotel_review) { create(:hotel, status: 'review', user: supervisor) }
  let!(:property_review) { create(:property, status: 'review', user: supervisor) }

  describe 'Authorization restrictions' do
    it 'redirects guest' do
      get admin_root_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects regular user with warning' do
      sign_in regular_user
      get admin_root_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('Доступ разрешён только администратору')
    end

    it 'allows admin access' do
      sign_in admin
      get admin_root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Модерация объектов')
    end
  end

  describe 'Approve Actions' do
    before { sign_in admin }

    it 'approves hotel and redirects' do
      patch admin_approve_hotel_path(hotel_review)
      expect(response).to redirect_to(admin_root_path)
      expect(hotel_review.reload.status).to eq('active')
      expect(flash[:notice]).to include('Отель одобрен')
    end

    it 'approves property and redirects' do
      patch admin_approve_property_path(property_review)
      expect(response).to redirect_to(admin_root_path)
      expect(property_review.reload.status).to eq('active')
      expect(flash[:notice]).to include('Жильё одобрено')
    end
  end

  describe 'Reject Actions' do
    before { sign_in admin }

    it 'rejects hotel and redirects' do
      patch admin_reject_hotel_path(hotel_review)
      expect(response).to redirect_to(admin_root_path)
      expect(hotel_review.reload.status).to eq('rejected')
      expect(flash[:notice]).to include('Отель отклонён')
    end

    it 'rejects property and redirects' do
      patch admin_reject_property_path(property_review)
      expect(response).to redirect_to(admin_root_path)
      expect(property_review.reload.status).to eq('rejected')
      expect(flash[:notice]).to include('Жильё отклонено')
    end
  end
end
