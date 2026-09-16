# frozen_string_literal: true

class Seat < ApplicationRecord
  belongs_to :trip

  has_many :hold_seats, dependent: :destroy
  has_many :booking_seats, dependent: :destroy

  validates :number, presence: true, numericality: { only_integer: true }
  validates :seat_type, presence: true, inclusion: { in: %w[seater sleeper] }
  validates :trip_id, uniqueness: { scope: :number }
end
