# frozen_string_literal: true

class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [:show, :cancel]

  def index
    @bookings = policy_scope(Booking)
                  .includes(room: :hotel)
                  .order(created_at: :desc)
                  .page(params[:page])
                  .per(10)
  end

  def show
    authorize @booking
  end

  def new
    @room = Room.find(params[:room_id])
    @hotel = @room.hotel
    @booking = Booking.new(
      room: @room,
      check_in: params[:check_in],
      check_out: params[:check_out],
      guests_count: params[:guests] || 1
    )
    authorize @booking
  end

  def create
    @room = Room.find(booking_params[:room_id])
    @booking = current_user.bookings.build(booking_params)
    authorize @booking

    if @booking.save
      redirect_to booking_path(@booking), notice: 'Бронирование успешно создано!'
    else
      @hotel = @room.hotel
      render :new, status: :unprocessable_entity
    end
  end

  def cancel
    authorize @booking

    if @booking.cancel!
      redirect_to bookings_path, notice: 'Бронирование отменено.'
    else
      redirect_to booking_path(@booking), alert: 'Невозможно отменить это бронирование.'
    end
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:room_id, :check_in, :check_out, :guests_count, :special_requests, :guest_name, :guest_phone, :guest_passport)
  end
end
