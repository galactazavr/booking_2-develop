# frozen_string_literal: true

class Supervisor::BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_supervisor!
  before_action :set_booking, only: [:show, :confirm]

  layout 'supervisor'

  def index
    query = Booking.joins(room: :hotel)
    if current_user.city.present?
      query = query.where(hotels: { city: current_user.city })
    else
      query = query.where(hotels: { user_id: current_user.id })
    end
    @bookings = query.includes(room: :hotel, user: [])
                     .order(created_at: :desc)
                     .page(params[:page])
                     .per(15)
  end

  def show
  end

  def confirm
    if @booking.confirm!
      redirect_to supervisor_booking_path(@booking), notice: 'Бронирование подтверждено.'
    else
      redirect_to supervisor_booking_path(@booking), alert: 'Невозможно подтвердить это бронирование.'
    end
  end

  private

  def require_supervisor!
    unless current_user.supervisor?
      redirect_to root_path, alert: 'Доступ запрещён. Только для менеджеров.'
    end
  end

  def set_booking
    query = Booking.joins(room: :hotel)
    if current_user.city.present?
      query = query.where(hotels: { city: current_user.city })
    else
      query = query.where(hotels: { user_id: current_user.id })
    end
    @booking = query.find(params[:id])
  end
end
