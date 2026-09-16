# frozen_string_literal: true

class BookingConfirmationService
  def self.call(user:, hold:)
    new(user: user, hold: hold).call
  end

  def initialize(user:, hold:)
    @user = user
    @hold = hold
  end

  def call
    hold = Hold.lock.find(@hold.id)
    existing_booking = Booking.find_by(hold_id: hold.id)
    return existing_booking if existing_booking.present?

    ActiveRecord::Base.transaction do
      hold = Hold.lock.find(@hold.id)
      if hold.expired?
        record = Booking.new
        record.errors.add(:base, "Hold is expired")
        raise ActiveRecord::RecordInvalid, record
      end

      if hold.user_id != @user.id
        record = Booking.new
        record.errors.add(:base, "Hold cannot be confirmed by another user")
        raise ActiveRecord::RecordInvalid, record
      end

      booking = Booking.create!(user: @user, trip: hold.trip, hold: hold, total_amount: hold.total_amount, status: "confirmed")

      hold.hold_seats.each do |hold_seat|
        BookingSeat.create!(booking: booking, seat: hold_seat.seat, price: hold_seat.price)
      end

      hold.update!(status: "converted")
      booking
    end
  end
end
