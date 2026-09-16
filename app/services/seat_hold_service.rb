# frozen_string_literal: true

class SeatHoldService
  include ActiveModel::Model

  attr_reader :user, :trip, :seat_ids

  def self.call(user:, trip:, seat_ids:)
    new(user: user, trip: trip, seat_ids: seat_ids).call
  end

  def initialize(user:, trip:, seat_ids:)
    @user = user
    @trip = trip
    @seat_ids = Array(seat_ids).map(&:to_i).uniq
  end

  def call
    if seat_ids.empty?
      record = Hold.new
      record.errors.add(:base, "Seat selection is required")
      raise ActiveRecord::RecordInvalid, record
    end

    ActiveRecord::Base.transaction do
      seats = @trip.seats.lock.where(id: seat_ids).order(:id)
      if seats.length != seat_ids.length
        record = Hold.new
        record.errors.add(:base, "Selected seats are not valid for this trip")
        raise ActiveRecord::RecordInvalid, record
      end

      conflicting_holds = Hold.active.joins(:hold_seats).where(hold_seats: { seat_id: seat_ids })
      if conflicting_holds.exists?
        record = Hold.new
        record.errors.add(:base, "One or more seats are already on hold")
        raise ActiveRecord::RecordInvalid, record
      end

      booking_conflicts = Booking.confirmed.joins(:booking_seats).where(booking_seats: { seat_id: seat_ids })
      if booking_conflicts.exists?
        record = Hold.new
        record.errors.add(:base, "One or more seats are already booked")
        raise ActiveRecord::RecordInvalid, record
      end

      hold = Hold.create!(user: @user, trip: @trip, expires_at: 5.minutes.from_now, status: "active", total_amount: seats.sum { |seat| @trip.base_price })

      seats.each do |seat|
        HoldSeat.create!(hold: hold, seat: seat, price: @trip.base_price)
      end

      hold
    end
  end
end
