# BusBook

BusBook is a Ruby on Rails application for searching bus trips and booking seats. It includes temporary seat holds, booking confirmation, cancellation and refund handling, background expiry processing, and user booking history.

The project is built as a standard Rails MVC application. Business rules that involve seat availability, booking confirmation, cancellation, and rescheduling are kept in service objects so the controllers stay small and easy to follow.

## Features

- Search buses by route, travel date, operator rating, price range, bus type, seat layout, and amenities.
- Preserve search filters after submitting the search form.
- Sign up and log in using Rails session authentication and bcrypt password hashing.
- Hold an available seat temporarily for five minutes.
- Prevent two users from holding or booking the same seat.
- Confirm a valid hold and create one booking for it.
- View all bookings belonging to the logged-in user.
- Cancel a booking more than one hour before departure.
- Deduct a flat INR 50 cancellation fee and store the refund amount.
- Expire unconfirmed holds automatically with Sidekiq.
- Cache trip search results for ten minutes.

## Application Flow

The normal customer flow is:

```text
Search buses
    |
    v
Click Book Now
    |
    v
Seat is held for five minutes
    |
    v
Confirm Booking
    |
    v
Booking Details
    |
    v
View My Bookings or cancel the booking
```

### Temporary hold flow

When the user clicks **Book Now**, the application locks the selected seat rows inside a database transaction. It checks that the seats belong to the selected trip and are not already held or booked. A successful hold is valid for five minutes and the user is redirected to the confirmation page.

If the user confirms in time, the hold is converted into a confirmed booking. If the user does not confirm, `HoldExpiryJob` changes the hold to `expired`, making the seat available again.

### Cancellation flow

Cancellation is allowed only when the trip departure is at least one hour away. When cancellation succeeds, the booking is marked as cancelled and INR 50 is deducted from the refund.

For example:

```text
Ticket price: INR 850
Cancellation fee: INR 50
Refund amount: INR 800
```

If the departure is within one hour, cancellation is rejected and the booking remains confirmed.

## Authentication

The application does not use Devise. It uses Rails built-in session authentication:

- `has_secure_password` for password hashing
- `bcrypt` for password verification
- `session[:user_id]` for login state

Demo account created by the seed file:

```text
Email: demo@example.com
Password: password123
```

## Technology Stack

- Ruby 3.2+
- Ruby on Rails 8.1
- PostgreSQL
- Sidekiq and Redis
- Active Job
- bcrypt
- RSpec
- Propshaft and Importmap

## Setup

Install the Ruby dependencies:

```bash
bundle install
```

Create and migrate the development database. Update the PostgreSQL username and password for your local machine if necessary:

```bash
PGUSER=ajay-binekar PGPASSWORD=postgres bin/rails db:create db:migrate
```

Load the sample operators, trips, amenities, and seats:

```bash
bin/rails db:seed
```

Start Rails:

```bash
bin/rails server
```

The application is available at [http://localhost:3000](http://localhost:3000).

## Running Sidekiq

Sidekiq is used to process hold expiry jobs outside the web request. Redis must be running first. Start Sidekiq in a second terminal:

```bash
bundle exec sidekiq
```

The application automatically schedules `HoldExpiryJob` after a hold is committed to the database.

## Testing Search Filters

The seed file creates multiple records so the filters can be tested from the UI or Rails console:

```bash
bin/rails console
```

```ruby
Trip.search(from_city: "Pune", to_city: "Mumbai")
Trip.search(bus_type: "ac")
Trip.search(seat_layout: "sleeper")
Trip.search(amenities: ["wifi"])
Trip.search(min_price: 400, max_price: 600)
Trip.search(operator_rating: 4.5)
```

## Running Tests

Run the complete RSpec suite:

```bash
bundle exec rspec
```

The test suite covers:

- User authentication and validation
- Trip search filters
- Seat availability
- Concurrent seat holds
- Duplicate booking prevention
- Hold expiry
- Booking cancellation and refund calculation

## Important Files

| Area | File |
| --- | --- |
| Trip search | `app/models/trip.rb` |
| Seat holding | `app/services/seat_hold_service.rb` |
| Booking confirmation | `app/services/booking_confirmation_service.rb` |
| Cancellation and refund | `app/services/cancellation_service.rb` |
| Hold expiry job | `app/jobs/hold_expiry_job.rb` |
| Booking controller | `app/controllers/bookings_controller.rb` |
| Seed data | `db/seeds.rb` |
| Database schema | `db/migrate/20260916000001_create_booking_platform.rb` |

## Screenshots

The application screens used for the assignment are:

1. Login page
2. Trip search and results page
3. Temporary seat hold and booking confirmation page
4. Booking details page
5. Cancelled booking details page
6. My Bookings page

Screenshots can be added to this section using image files such as:

```markdown
![Trip search page](docs/screenshots/trip-search.png)
![Booking confirmation page](docs/screenshots/booking-confirmation.png)
![Booking details page](docs/screenshots/booking-details.png)
![My bookings page](docs/screenshots/my-bookings.png)
```

## Design Decisions

Seat availability is calculated from the trip's seats, active holds, and confirmed bookings. Seat holds use database row locking and transactions to prevent overselling. Booking confirmation is idempotent, so submitting the same hold more than once does not create duplicate bookings.
