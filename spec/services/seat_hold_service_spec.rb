# frozen_string_literal: true

require "rails_helper"

RSpec.describe SeatHoldService do
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
  let(:user_one) { User.create!(email: "one@example.com", password: "password123", password_confirmation: "password123") }
  let(:user_two) { User.create!(email: "two@example.com", password: "password123", password_confirmation: "password123") }

  before do
    3.times { |index| trip.seats.create!(number: index + 1, seat_type: "seater") }
  end

  it "creates an active temporary hold for available seats" do
    hold = described_class.call(user: user_one, trip: trip, seat_ids: [ trip.seats.first.id ])

    expect(hold).to be_persisted
    expect(hold.status).to eq("active")
    expect(hold.expires_at).to be > Time.current
  end

  it "prevents two users from holding the same seat at the same time" do
    first_hold = described_class.call(user: user_one, trip: trip, seat_ids: [ trip.seats.first.id ])

    expect(first_hold).to be_persisted

    expect do
      described_class.call(user: user_two, trip: trip, seat_ids: [ trip.seats.first.id ])
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "allows a seat to be held again after the previous hold expires" do
    first_hold = described_class.call(user: user_one, trip: trip, seat_ids: [ trip.seats.first.id ])
    first_hold.update!(status: "expired")

    next_hold = described_class.call(user: user_two, trip: trip, seat_ids: [ trip.seats.first.id ])

    expect(next_hold).to be_persisted
    expect(next_hold.status).to eq("active")
  end
end
