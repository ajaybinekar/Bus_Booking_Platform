# frozen_string_literal: true

class BookingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @bookings = current_user.bookings.includes(:trip, :seats).order(created_at: :desc)
  end

  def show
    @booking = Booking.find(params[:id])
  end

  def new
    @trip = Trip.find(params[:trip_id])
    @available_seats = @trip.available_seats
  end

  def create
    trip = Trip.find(params[:trip_id])
    hold = SeatHoldService.call(user: current_user, trip: trip, seat_ids: params[:seat_ids])
    redirect_to confirm_booking_path(hold_id: hold.id), notice: "Seats temporarily held for 5 minutes."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to trips_path, alert: e.message
  end

  def confirm
    @hold = Hold.find(params[:hold_id])
    return render :confirm if request.get?

    booking = BookingConfirmationService.call(user: current_user, hold: @hold)
    redirect_to booking_path(booking), notice: "Booking confirmed successfully."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to trips_path, alert: e.message
  end

  def cancel
    booking = Booking.find(params[:id])
    cancelled_booking = CancellationService.call(user: current_user, booking: booking)
    redirect_to booking_path(cancelled_booking), notice: "Booking cancelled successfully. A ₹50 cancellation fee was deducted. Refund amount: ₹#{cancelled_booking.refund_amount}."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to booking_path(booking), alert: e.message
  end

  private

  def authenticate_user!
    return if session[:user_id].present?

    redirect_to login_path, alert: "Please sign in first."
  end
end
