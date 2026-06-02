# frozen_string_literal: true

class BookingMailer < ApplicationMailer
  default from: 'noreply@checqin.ru'

  # Клиенту: бронирование создано
  def booking_created(booking)
    @booking = booking
    @user = booking.user
    @hotel = booking.room.hotel
    @room = booking.room
    mail(to: @user.email, subject: "Бронирование ##{booking.id} создано — #{@hotel.name}")
  end

  # Клиенту: бронирование подтверждено
  def booking_confirmed(booking)
    @booking = booking
    @user = booking.user
    @hotel = booking.room.hotel
    mail(to: @user.email, subject: "Бронирование ##{booking.id} подтверждено!")
  end

  # Клиенту: бронирование отменено
  def booking_cancelled(booking)
    @booking = booking
    @user = booking.user
    @hotel = booking.room.hotel
    mail(to: @user.email, subject: "Бронирование ##{booking.id} отменено")
  end

  # Менеджеру: новое бронирование
  def new_booking_notification(booking)
    @booking = booking
    @hotel = booking.room.hotel
    @manager = @hotel.user
    return unless @manager

    mail(to: @manager.email, subject: "Новое бронирование ##{booking.id} в #{@hotel.name}")
  end
end
