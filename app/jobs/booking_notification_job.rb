# frozen_string_literal: true

class BookingNotificationJob < ApplicationJob
  queue_as :default

  def perform(booking_id, event)
    booking = Booking.find_by(id: booking_id)
    return unless booking

    case event.to_s
    when 'created'
      BookingMailer.booking_created(booking).deliver_later
      BookingMailer.new_booking_notification(booking).deliver_later

      # Client notification
      Notification.create!(
        user: booking.user,
        booking: booking,
        title: 'Бронирование создано',
        message: "Ваше бронирование ##{booking.id} в #{booking.room.hotel.name} создано и ожидает подтверждения."
      )
      # Manager notification
      manager = booking.room.hotel.user
      if manager
        Notification.create!(
          user: manager,
          booking: booking,
          title: 'Новое бронирование',
          message: "Новое бронирование ##{booking.id} в #{booking.room.hotel.name} от #{booking.user.full_name} ожидает подтверждения."
        )
      end
    when 'confirmed'
      BookingMailer.booking_confirmed(booking).deliver_later

      # Client notification
      Notification.create!(
        user: booking.user,
        booking: booking,
        title: 'Бронирование подтверждено',
        message: "Ваше бронирование ##{booking.id} в #{booking.room.hotel.name} успешно подтверждено!"
      )
    when 'cancelled'
      BookingMailer.booking_cancelled(booking).deliver_later

      # Client notification
      Notification.create!(
        user: booking.user,
        booking: booking,
        title: 'Бронирование отменено',
        message: "Ваше бронирование ##{booking.id} в #{booking.room.hotel.name} отменено."
      )
      # Manager notification
      manager = booking.room.hotel.user
      if manager
        Notification.create!(
          user: manager,
          booking: booking,
          title: 'Бронирование отменено',
          message: "Бронирование ##{booking.id} в #{booking.room.hotel.name} отменено."
        )
      end
    when 'completed'
      # Client notification
      Notification.create!(
        user: booking.user,
        booking: booking,
        title: 'Поездка завершена',
        message: "Ваша поездка в #{booking.room.hotel.name} завершена. Пожалуйста, оставьте отзыв об отеле!"
      )
    end
  end
end
