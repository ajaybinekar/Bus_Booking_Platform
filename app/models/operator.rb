# frozen_string_literal: true

class Operator < ApplicationRecord
  has_many :trips, dependent: :destroy

  validates :name, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
end
