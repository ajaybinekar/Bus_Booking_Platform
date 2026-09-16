# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :holds, dependent: :destroy
  has_many :bookings, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: :password_digest_changed?

  before_validation { self.email = email.to_s.strip.downcase }

  def self.authenticate(email, password)
    find_by(email: email.to_s.strip.downcase)&.authenticate(password)
  end
end
