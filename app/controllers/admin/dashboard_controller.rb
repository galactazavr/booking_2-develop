class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_hotel, only: [:approve_hotel, :reject_hotel]
  before_action :set_property, only: [:approve_property, :reject_property]

  layout 'admin'

  def index
    @hotels = Hotel.review.includes(:user).order(created_at: :desc)
    @properties = Property.review.includes(:user).order(created_at: :desc)
    @history_hotels = Hotel.where(status: ['active', 'rejected']).includes(:user).order(updated_at: :desc).limit(10)
    @history_properties = Property.where(status: ['active', 'rejected']).includes(:user).order(updated_at: :desc).limit(10)
  end

  def approve_hotel
    update_status(@hotel, 'active', 'Отель одобрен и опубликован.')
  end

  def reject_hotel
    update_status(@hotel, 'rejected', 'Отель отклонён.')
  end

  def approve_property
    update_status(@property, 'active', 'Жильё одобрено и опубликовано.')
  end

  def reject_property
    update_status(@property, 'rejected', 'Жильё отклонено.')
  end

  private

  def set_hotel
    @hotel = Hotel.find(params[:id])
  end

  def set_property
    @property = Property.find(params[:id])
  end

  def update_status(record, status, notice)
    record.update!(status: status)
    redirect_to admin_root_path, notice: notice
  end
end
