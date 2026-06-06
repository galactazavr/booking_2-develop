# frozen_string_literal: true

class HotelsController < ApplicationController
  before_action :set_hotel, only: [:show, :destroy]

  def index
    @hotels = Hotel.active
                   .order(created_at: :desc)
                   .page(params[:page])
                   .per(12)
    @popular_cities = Hotel.active.distinct.pluck(:city).first(5)
    @popular_cities = ['Москва', 'Санкт-Петербург', 'Сочи', 'Казань', 'Калининград'] if @popular_cities.empty?
  end

  def search
    @city = params[:city]
    @checkin = parse_date(params[:checkin])
    @checkout = parse_date(params[:checkout])
    @guests = params[:guests].to_i
    @min_price = params[:min_price]
    @max_price = params[:max_price]
    @category = params[:category] || 'отели'
    @sort = params[:sort] || 'price_asc'

    # Выбор базовой модели в зависимости от категории
    if @category == 'апартаменты'
      @results = Property.active
    elsif @category == 'хостелы'
      @results = Hotel.active.where(hotel_type: 'Хостел')
    else # 'отели'
      @results = Hotel.active.where(hotel_type: 'Отель')
    end

    # Фильтрация по городу
    @results = @results.by_city(@city) if @city.present?

    # Фильтрация по датам доступности
    @results = @results.available_for_stay(@checkin, @checkout)

    # Фильтрация по цене
    if @min_price.present? || @max_price.present?
      min = @min_price.present? ? @min_price.to_d : 0
      max = @max_price.present? ? @max_price.to_d : Float::INFINITY
      @results = @results.where(base_price_per_night: min..max)
    end

    # Сортировка по цене
    if @sort == 'price_desc'
      @results = @results.order(base_price_per_night: :desc)
    else
      @results = @results.order(base_price_per_night: :asc)
    end

    @results = @results.page(params[:page]).per(12)

    # Сохраняем в @hotels для совместимости со вьюхами
    @hotels = @results

    render :search
  end

  def show
    @rooms = @hotel.rooms.available.order(:price_per_night)
  end

  def destroy
    reason = params[:deletion_reason].presence || "Отель закрылся или был снесён"

    # Notify users about booking cancellations due to hotel deletion
    active_bookings = Booking.joins(:room).where(rooms: { hotel_id: @hotel.id }, status: ['pending', 'confirmed'])
    active_bookings.each do |booking|
      Notification.create!(
        user: booking.user,
        title: "Бронирование отменено",
        body: "Ваше бронирование №#{booking.id} в отеле \"#{@hotel.name}\" было отменено. Причина: #{reason}",
        notification_type: 'booking_cancelled'
      )

      begin
        BookingMailer.booking_notification(booking, "Ваше бронирование отменено, так как отель был удален по причине: #{reason}").deliver_later
      rescue => e
        logger.error "Failed to send cancellation email for booking #{booking.id}: #{e.message}"
      end
    end

    @hotel.update!(status: 'deleted', deletion_reason: reason)
    redirect_to request.referer || root_path, notice: "Отель \"#{@hotel.name}\" успешно удалён. Активные бронирования отменены."
  end

  private

  def set_hotel
    @hotel = Hotel.find(params[:id])
    authorize @hotel
  end

  def parse_date(value)
    return if value.blank?

    Date.parse(value)
  rescue ArgumentError
    nil
  end
end
