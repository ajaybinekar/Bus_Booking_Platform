# frozen_string_literal: true

class BookingSeat < ApplicationRecord
  belongs_to :booking
  belongs_to :seat

  validates :seat_id, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
end
