# frozen_string_literal: true

class Hold < ApplicationRecord
  belongs_to :user
  belongs_to :trip

  has_many :hold_seats, dependent: :destroy
  has_many :seats, through: :hold_seats
  has_one :booking, dependent: :restrict_with_exception

  after_create_commit :enqueue_expiry_job

  validates :expires_at, presence: true
  validates :status, inclusion: { in: %w[active expired converted] }

  scope :active, -> { where(status: "active").where("expires_at > ?", Time.current) }

  def expired?
    status == "expired" || expires_at <= Time.current
  end

  def convert!
    update!(status: "converted")
  end

  private

  def enqueue_expiry_job
    HoldExpiryJob.set(wait_until: expires_at).perform_later(id)
  end
end
