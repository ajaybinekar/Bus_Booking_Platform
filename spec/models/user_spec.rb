# frozen_string_literal: true

require "rails_helper"

RSpec.describe User do
  it "normalizes email before validation" do
    user = described_class.create!(email: "  PERSON@EXAMPLE.COM ", password: "password123", password_confirmation: "password123")

    expect(user.email).to eq("person@example.com")
  end

  it "authenticates with a valid password" do
    user = described_class.create!(email: "auth@example.com", password: "password123", password_confirmation: "password123")

    expect(described_class.authenticate("AUTH@example.com", "password123")).to eq(user)
  end

  it "rejects an invalid password" do
    user = described_class.create!(email: "wrong@example.com", password: "password123", password_confirmation: "password123")

    expect(described_class.authenticate(user.email, "wrong-password")).to be_falsey
  end

  it "requires a valid email" do
    user = described_class.new(email: "not-an-email", password: "password123", password_confirmation: "password123")

    expect(user).not_to be_valid
    expect(user.errors[:email]).not_to be_empty
  end
end
