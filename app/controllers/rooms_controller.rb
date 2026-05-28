# frozen_string_literal: true

class RoomsController < ApplicationController
  before_action :set_hotel
  before_action :set_room, only: [:show]

  def index
    @rooms = @hotel.rooms.order(:price_per_night)
  end

  def show
  end

  private

  def set_hotel
    @hotel = Hotel.find(params[:hotel_id])
  end

  def set_room
    @room = @hotel.rooms.find(params[:id])
    authorize @room
  end
end
