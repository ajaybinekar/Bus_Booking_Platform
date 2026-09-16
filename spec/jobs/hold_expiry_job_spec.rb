# frozen_string_literal: true

require "rails_helper"

RSpec.describe HoldExpiryJob do
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
  let(:user) { User.create!(email: "expiry@example.com", password: "password123", password_confirmation: "password123") }

  before do
    trip.seats.create!(number: 1, seat_type: "seater")
  end

  it "expires an active hold when the window has passed" do
    hold = SeatHoldService.call(user: user, trip: trip, seat_ids: [ trip.seats.first.id ])
    hold.update!(expires_at: 1.minute.ago)

    described_class.perform_now(hold.id)

    expect(hold.reload.status).to eq("expired")
  end
end
