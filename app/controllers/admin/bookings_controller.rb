# frozen_string_literal: true

class Admin::BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  layout 'admin'

  def index
    @bookings = Booking.includes(room: :hotel, user: [])
                       .order(created_at: :desc)
                       .page(params[:page])
                       .per(20)
  end

  def show
    @booking = Booking.find(params[:id])
  end
end
