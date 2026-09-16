# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_16_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "booking_seats", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.datetime "created_at", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.bigint "seat_id", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id", "seat_id"], name: "index_booking_seats_unique_booking_and_seat", unique: true
    t.index ["booking_id"], name: "index_booking_seats_on_booking_id"
    t.index ["seat_id"], name: "index_booking_seats_on_seat_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.bigint "hold_id", null: false
    t.decimal "refund_amount", precision: 10, scale: 2, default: "0.0"
    t.string "status", default: "confirmed", null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.bigint "trip_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["hold_id"], name: "index_bookings_on_hold_id"
    t.index ["hold_id"], name: "index_bookings_unique_hold_id", unique: true
    t.index ["trip_id"], name: "index_bookings_on_trip_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "hold_seats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "hold_id", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.bigint "seat_id", null: false
    t.datetime "updated_at", null: false
    t.index ["hold_id", "seat_id"], name: "index_hold_seats_unique_hold_and_seat", unique: true
    t.index ["hold_id"], name: "index_hold_seats_on_hold_id"
    t.index ["seat_id"], name: "index_hold_seats_on_seat_id"
  end

  create_table "holds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "status", default: "active", null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.bigint "trip_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["trip_id"], name: "index_holds_on_trip_id"
    t.index ["user_id"], name: "index_holds_on_user_id"
  end

  create_table "operators", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.decimal "rating", precision: 3, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
  end

  create_table "seats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "number", null: false
    t.string "seat_type", default: "seater", null: false
    t.bigint "trip_id", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id", "number"], name: "index_seats_on_trip_id_and_number", unique: true
    t.index ["trip_id"], name: "index_seats_on_trip_id"
  end

  create_table "trips", force: :cascade do |t|
    t.text "amenities", default: [], array: true
    t.datetime "arrival_at", null: false
    t.decimal "base_price", precision: 10, scale: 2, null: false
    t.string "bus_type", null: false
    t.datetime "created_at", null: false
    t.datetime "departure_at", null: false
    t.string "from_city", null: false
    t.bigint "operator_id", null: false
    t.string "seat_layout", null: false
    t.string "status", default: "scheduled", null: false
    t.string "to_city", null: false
    t.datetime "updated_at", null: false
    t.index ["operator_id"], name: "index_trips_on_operator_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "booking_seats", "bookings"
  add_foreign_key "booking_seats", "seats"
  add_foreign_key "bookings", "holds"
  add_foreign_key "bookings", "trips"
  add_foreign_key "bookings", "users"
  add_foreign_key "hold_seats", "holds"
  add_foreign_key "hold_seats", "seats"
  add_foreign_key "holds", "trips"
  add_foreign_key "holds", "users"
  add_foreign_key "seats", "trips"
  add_foreign_key "trips", "operators"
end
