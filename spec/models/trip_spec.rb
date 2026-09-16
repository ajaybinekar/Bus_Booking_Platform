# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trip do
  let(:operator) { Operator.create!(name: "Test Travels", rating: 4.5) }
  let(:trip_date) { 2.days.from_now.to_date }
  let!(:trip) do
    Trip.create!(
      operator: operator,
      from_city: "Pune",
      to_city: "Mumbai",
      departure_at: trip_date.to_time.change(hour: 18),
      arrival_at: trip_date.to_time.change(hour: 22),
      base_price: 500,
      bus_type: "ac",
      seat_layout: "sleeper",
      status: "scheduled",
      amenities: %w[wifi charging]
    )
  end
  let!(:other_trip) do
    Trip.create!(
      operator: operator,
      from_city: "Pune",
      to_city: "Goa",
      departure_at: trip_date.to_time.change(hour: 20),
      arrival_at: (trip_date + 1).to_time.change(hour: 6),
      base_price: 900,
      bus_type: "non_ac",
      seat_layout: "seater",
      status: "scheduled",
      amenities: [ "water" ]
    )
  end
  let(:user) { User.create!(email: "trip-spec@example.com", password: "password123", password_confirmation: "password123") }

  before do
    2.times { |index| trip.seats.create!(number: index + 1, seat_type: "sleeper") }
  end

  it "filters by route case-insensitively" do
    expect(described_class.search(from_city: "pUnE", to_city: "mUmBaI")).to include(trip)
    expect(described_class.search(from_city: "Pune", to_city: "Goa")).to include(other_trip)
  end

  it "filters by date, rating, price, bus type, and layout" do
    results = described_class.search(
      travel_date: trip_date.to_s,
      operator_rating: 4.5,
      min_price: 400,
      max_price: 600,
      bus_type: "ac",
      seat_layout: "sleeper"
    )

    expect(results).to contain_exactly(trip)
  end

  it "filters by any matching amenity and ignores blank values" do
    expect(described_class.search(amenities: [ "", "wifi" ])).to include(trip)
    expect(described_class.search(amenities: [ "water" ])).to include(other_trip)
  end

  it "returns seats in number order" do
    expect(trip.available_seats.pluck(:number)).to eq([ 1, 2 ])
  end

  it "removes actively held seats from availability" do
    hold = SeatHoldService.call(user: user, trip: trip, seat_ids: [ trip.seats.first.id ])

    expect(trip.reload.available_seats.pluck(:id)).to eq([ trip.seats.second.id ])
    expect(hold.seats).to include(trip.seats.first)
  end

  it "removes confirmed booking seats from availability" do
    hold = SeatHoldService.call(user: user, trip: trip, seat_ids: [ trip.seats.first.id ])
    BookingConfirmationService.call(user: user, hold: hold)

    expect(trip.reload.available_seats.pluck(:id)).to eq([ trip.seats.second.id ])
  end
end
