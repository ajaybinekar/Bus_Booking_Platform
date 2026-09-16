# frozen_string_literal: true

require "rails_helper"

RSpec.describe CancellationService do
  let(:operator) { Operator.create!(name: "Royal Travels", rating: 4.8) }
  let(:trip) do
    Trip.create!(
      operator: operator,
      from_city: "Pune",
      to_city: "Mumbai",
      departure_at: 2.days.from_now.change(hour: 18, min: 30),
      arrival_at: 2.days.from_now.change(hour: 22, min: 0),
      base_price: 850,
      bus_type: "ac",
      seat_layout: "seater",
      status: "scheduled"
    )
  end
  let(:user) { User.create!(email: "cancel@example.com", password: "password123", password_confirmation: "password123") }

  before do
    trip.seats.create!(number: 1, seat_type: "seater")
  end

  it "cancels a booking and refunds the ticket price minus the flat fee if it is more than an hour away" do
    hold = SeatHoldService.call(user: user, trip: trip, seat_ids: [ trip.seats.first.id ])
    booking = BookingConfirmationService.call(user: user, hold: hold)

    result = described_class.call(user: user, booking: booking)

    expect(result.status).to eq("cancelled")
    expect(result.refund_amount).to eq(800)
  end

  it "returns a validation error when cancellation is within one hour of departure" do
    trip.update!(departure_at: 30.minutes.from_now)
    hold = SeatHoldService.call(user: user, trip: trip, seat_ids: [ trip.seats.first.id ])
    booking = BookingConfirmationService.call(user: user, hold: hold)

    expect do
      described_class.call(user: user, booking: booking)
    end.to raise_error(ActiveRecord::RecordInvalid, /at least 1 hour before departure/)
  end

  it "rejects cancellation by another user" do
    another_user = User.create!(email: "other-cancel@example.com", password: "password123", password_confirmation: "password123")
    hold = SeatHoldService.call(user: user, trip: trip, seat_ids: [ trip.seats.first.id ])
    booking = BookingConfirmationService.call(user: user, hold: hold)

    expect do
      described_class.call(user: another_user, booking: booking)
    end.to raise_error(ActiveRecord::RecordInvalid, /another user/)
  end
end
