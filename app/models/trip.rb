# frozen_string_literal: true

class Trip < ApplicationRecord
  belongs_to :operator
  has_many :seats, dependent: :destroy
  has_many :holds, dependent: :destroy
  has_many :bookings, dependent: :destroy

  validates :from_city, :to_city, :departure_at, :arrival_at, :base_price, presence: true
  validates :bus_type, inclusion: { in: %w[ac non_ac] }
  validates :seat_layout, inclusion: { in: %w[seater sleeper] }
  validates :status, inclusion: { in: %w[scheduled cancelled completed] }

  scope :by_route, ->(from_city, to_city) { where(from_city: from_city, to_city: to_city) }
  scope :available_on, ->(date) { where("DATE(departure_at) = ?", date.to_date) }

  def self.search(filters = {})
    relation = includes(:operator)
    relation = relation.where("LOWER(from_city) = ?", filters[:from_city].to_s.strip.downcase) if filters[:from_city].present?
    relation = relation.where("LOWER(to_city) = ?", filters[:to_city].to_s.strip.downcase) if filters[:to_city].present?
    relation = relation.where("DATE(departure_at) = ?", filters[:travel_date].to_date) if filters[:travel_date].present?
    relation = relation.joins(:operator).where("operators.rating >= ?", filters[:operator_rating].to_f) if filters[:operator_rating].present?
    relation = relation.where("base_price BETWEEN ? AND ?", filters[:min_price].to_f, filters[:max_price].to_f) if filters[:min_price].present? && filters[:max_price].present?
    relation = relation.where(bus_type: filters[:bus_type]) if filters[:bus_type].present?
    relation = relation.where(seat_layout: filters[:seat_layout]) if filters[:seat_layout].present?
    if filters[:amenities].present?
      amenities_param = Array(filters[:amenities]).filter_map { |amenity| amenity.presence }.uniq
      relation = relation.where("amenities && ARRAY[?]::text[]", amenities_param) if amenities_param.any?
    end
    relation.order(departure_at: :asc)
  end

  def self.expire_search_cache!
    Rails.cache.delete_matched("trip_search/*")
  end

  def available_seats
    seat_ids = seats.pluck(:id) - holds.active.joins(:hold_seats).pluck("hold_seats.seat_id") - bookings.confirmed.joins(:booking_seats).pluck("booking_seats.seat_id")
    Seat.where(id: seat_ids).order(:number)
  end
end
