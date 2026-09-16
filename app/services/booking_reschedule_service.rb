# frozen_string_literal: true

class BookingRescheduleService
  def self.call(user:, booking:, new_trip:)
    new(user: user, booking: booking, new_trip: new_trip).call
  end

  def initialize(user:, booking:, new_trip:)
    @user = user
    @booking = booking
    @new_trip = new_trip
  end

  def call
    ActiveRecord::Base.transaction do
      booking = Booking.lock.find(@booking.id)

      if booking.user_id != @user.id
        record = Booking.new
        record.errors.add(:base, "Booking can only be rescheduled by the owner")
        raise ActiveRecord::RecordInvalid, record
      end

      if booking.cancelled?
        record = Booking.new
        record.errors.add(:base, "Cancelled bookings cannot be rescheduled")
        raise ActiveRecord::RecordInvalid, record
      end

      if booking.trip.operator_id != @new_trip.operator_id || booking.trip.from_city != @new_trip.from_city || booking.trip.to_city != @new_trip.to_city
        record = Booking.new
        record.errors.add(:base, "Reschedule must be for the same route and operator")
        raise ActiveRecord::RecordInvalid, record
      end

      new_seat_numbers = booking.seats.pluck(:number)
      requested_seats = @new_trip.seats.where(number: new_seat_numbers)
      if requested_seats.count != new_seat_numbers.count
        record = Booking.new
        record.errors.add(:base, "Selected seats are not available on the new trip")
        raise ActiveRecord::RecordInvalid, record
      end

      booking.booking_seats.delete_all
      requested_seats.each do |seat|
        BookingSeat.create!(booking: booking, seat: seat, price: booking.total_amount / new_seat_numbers.count)
      end

      booking.update!(trip: @new_trip)
      Trip.expire_search_cache!
      booking
    end
  end
end
