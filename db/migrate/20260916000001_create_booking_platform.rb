class CreateBookingPlatform < ActiveRecord::Migration[8.1]
  def change
    create_table :operators do |t|
      t.string :name, null: false
      t.decimal :rating, precision: 3, scale: 2, default: 0.0

      t.timestamps
    end

    create_table :users do |t|
      t.string :email, null: false
      t.string :name
      t.string :password_digest, null: false

      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :trips do |t|
      t.references :operator, null: false, foreign_key: true
      t.string :from_city, null: false
      t.string :to_city, null: false
      t.datetime :departure_at, null: false
      t.datetime :arrival_at, null: false
      t.decimal :base_price, precision: 10, scale: 2, null: false
      t.string :bus_type, null: false
      t.string :seat_layout, null: false
      t.string :status, null: false, default: "scheduled"
      t.text :amenities, array: true, default: []

      t.timestamps
    end

    create_table :seats do |t|
      t.references :trip, null: false, foreign_key: true
      t.integer :number, null: false
      t.string :seat_type, null: false, default: "seater"

      t.timestamps
    end
    add_index :seats, [ :trip_id, :number ], unique: true

    create_table :holds do |t|
      t.references :user, null: false, foreign_key: true
      t.references :trip, null: false, foreign_key: true
      t.string :status, null: false, default: "active"
      t.datetime :expires_at, null: false
      t.decimal :total_amount, precision: 10, scale: 2, null: false

      t.timestamps
    end

    create_table :hold_seats do |t|
      t.references :hold, null: false, foreign_key: true
      t.references :seat, null: false, foreign_key: true
      t.decimal :price, precision: 10, scale: 2, null: false

      t.timestamps
    end
    add_index :hold_seats, [ :hold_id, :seat_id ], unique: true, name: "index_hold_seats_unique_hold_and_seat"

    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :trip, null: false, foreign_key: true
      t.references :hold, null: false, foreign_key: true
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.decimal :refund_amount, precision: 10, scale: 2, default: 0.0
      t.string :status, null: false, default: "confirmed"
      t.datetime :cancelled_at

      t.timestamps
    end

    create_table :booking_seats do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :seat, null: false, foreign_key: true
      t.decimal :price, precision: 10, scale: 2, null: false

      t.timestamps
    end
    add_index :booking_seats, [ :booking_id, :seat_id ], unique: true, name: "index_booking_seats_unique_booking_and_seat"
    add_index :bookings, :hold_id, unique: true, name: "index_bookings_unique_hold_id"
  end
end
