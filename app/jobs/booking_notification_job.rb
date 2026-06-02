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
    when 'confirmed'
      BookingMailer.booking_confirmed(booking).deliver_later
    when 'cancelled'
      BookingMailer.booking_cancelled(booking).deliver_later
    end
  end
end
