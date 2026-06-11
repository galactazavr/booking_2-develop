# frozen_string_literal: true

class Admin::BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  layout 'admin'

  def index
    @bookings = Booking.includes(room: :hotel, user: []).order(created_at: :desc)

    if params[:status].present?
      @bookings = @bookings.where(status: params[:status])
    end

    if params[:start_date].present?
      @bookings = @bookings.where('bookings.check_in >= ?', params[:start_date])
    end

    if params[:end_date].present?
      @bookings = @bookings.where('bookings.check_out <= ?', params[:end_date])
    end

    if params[:query].present?
      q = "%#{params[:query].downcase}%"
      @bookings = @bookings.joins(:user, room: :hotel)
                           .where(
                             'LOWER(users.first_name) LIKE :q OR LOWER(users.last_name) LIKE :q OR LOWER(users.email) LIKE :q OR LOWER(hotels.name) LIKE :q OR LOWER(bookings.guest_name) LIKE :q',
                             q: q
                           ).distinct
    end

    @bookings = @bookings.page(params[:page]).per(20)
  end

  def show
    @booking = Booking.find(params[:id])
  end
end
