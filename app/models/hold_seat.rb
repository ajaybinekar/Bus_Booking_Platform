# frozen_string_literal: true

class HoldSeat < ApplicationRecord
  belongs_to :hold
  belongs_to :seat

  validates :seat_id, uniqueness: { scope: :hold_id }
  validates :price, presence: true, numericality: { greater_than: 0 }
end
