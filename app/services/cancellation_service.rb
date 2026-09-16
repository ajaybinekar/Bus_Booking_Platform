# frozen_string_literal: true

class CancellationService
  def self.call(user:, booking:)
    new(user: user, booking: booking).call
  end

  def initialize(user:, booking:)
    @user = user
    @booking = booking
  end

  def call
    ActiveRecord::Base.transaction do
      booking = Booking.lock.find(@booking.id)
      raise_invalid("Booking cannot be cancelled by another user") if booking.user_id != @user.id
      raise_invalid("Booking is already cancelled") if booking.cancelled?

      departure = booking.trip.departure_at
      if departure - Time.current < 1.hour
        raise_invalid("Cancellation must be requested at least 1 hour before departure. A ₹50 cancellation fee applies when cancellation is allowed.")
      end

      refund_amount = booking.total_amount - 50
      booking.update!(status: "cancelled", cancelled_at: Time.current, refund_amount: refund_amount)
      booking
    end
  end

  private

  def raise_invalid(message)
    record = Booking.new
    record.errors.add(:base, message)
    raise ActiveRecord::RecordInvalid, record
  end
end
