# frozen_string_literal: true

require "rails_helper"

RSpec.describe BookingConfirmationService do
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
  let(:user) { User.create!(email: "booker@example.com", password: "password123", password_confirmation: "password123") }

  before do
    trip.seats.create!(number: 1, seat_type: "seater")
  end

  it "creates a booking only once for the same valid hold" do
    hold = SeatHoldService.call(user: user, trip: trip, seat_ids: [ trip.seats.first.id ])

    booking_one = described_class.call(user: user, hold: hold)
    booking_two = described_class.call(user: user, hold: hold)

    expect(booking_one).to eq(booking_two)
    expect(Booking.count).to eq(1)
  end
end
