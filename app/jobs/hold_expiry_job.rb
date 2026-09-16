# frozen_string_literal: true

class HoldExpiryJob < ApplicationJob
  queue_as :default

  def perform(hold_id)
    hold = Hold.find_by(id: hold_id)
    return if hold.nil?
    return if hold.status == "converted"

    hold.update!(status: "expired") if hold.expires_at <= Time.current
  end
end
