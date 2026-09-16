# frozen_string_literal: true

class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :trip
  belongs_to :hold

  has_many :booking_seats, dependent: :destroy
  has_many :seats, through: :booking_seats

  validates :status, inclusion: { in: %w[confirmed cancelled] }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }

  scope :confirmed, -> { where(status: "confirmed") }

  def cancelled?
    status == "cancelled"
  end
end
