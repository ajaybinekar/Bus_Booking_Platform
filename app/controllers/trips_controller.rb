# frozen_string_literal: true

class TripsController < ApplicationController
  def index
    cache_key = [ "trip_search", params.to_unsafe_h.to_h.sort ]
    @trips = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
      Trip.search(search_params).includes(:operator)
    end
  end

  private

  def search_params
    params.permit(:from_city, :to_city, :travel_date, :operator_rating, :min_price, :max_price, :bus_type, :seat_layout, amenities: [])
  end
end
