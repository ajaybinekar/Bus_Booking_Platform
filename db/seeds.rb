demo_user = User.find_or_create_by!(email: "demo@example.com") do |user|
  user.name = "Demo User"
  user.password = "password123"
  user.password_confirmation = "password123"
end

operators = {
  "Maharashtra Express" => 4.8,
  "CityLink Travels" => 4.3,
  "Budget Roadways" => 3.9
}

operators.each do |name, rating|
  Operator.find_or_create_by!(name: name) { |operator| operator.rating = rating }
end

trips = [
  [ "Maharashtra Express", "Pune", "Mumbai", 1.day.from_now.change(hour: 18, min: 30), 4.hours, 850, "ac", "seater", %w[wifi charging] ],
  [ "Maharashtra Express", "Nagpur", "Mumbai", 1.day.from_now.change(hour: 20), 10.hours, 550, "ac", "sleeper", %w[wifi water] ],
  [ "CityLink Travels", "Pune", "Mumbai", 2.days.from_now.change(hour: 7), 4.hours, 450, "non_ac", "seater", %w[charging] ],
  [ "CityLink Travels", "Mumbai", "Nashik", 2.days.from_now.change(hour: 22), 5.hours, 650, "ac", "sleeper", %w[wifi charging water] ],
  [ "Budget Roadways", "Pune", "Goa", 3.days.from_now.change(hour: 21), 11.hours, 700, "non_ac", "sleeper", %w[water] ],
  [ "Budget Roadways", "Nagpur", "Pune", 4.days.from_now.change(hour: 6), 10.hours, 400, "non_ac", "seater", [] ]
]

trips.each do |operator_name, from_city, to_city, departure_at, arrival_at, price, bus_type, seat_layout, amenities|
  operator = Operator.find_by!(name: operator_name)
  arrival_at = departure_at + arrival_at
  trip = Trip.find_or_create_by!(operator: operator, from_city: from_city, to_city: to_city, departure_at: departure_at) do |record|
    record.arrival_at = arrival_at
    record.base_price = price
    record.bus_type = bus_type
    record.seat_layout = seat_layout
    record.status = "scheduled"
    record.amenities = amenities
  end

  6.times do |index|
    trip.seats.find_or_create_by!(number: index + 1) { |seat| seat.seat_type = seat_layout == "sleeper" ? "sleeper" : "seater" }
  end
end

puts "Seeded #{Operator.count} operators, #{Trip.count} trips, and #{Seat.count} seats."
puts "Demo login: #{demo_user.email} / password123"
