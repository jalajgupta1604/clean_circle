class PickupsController < ApplicationController
  before_action :require_customer!

  def index
    household = current_user.household

    unless household
      redirect_to new_household_path, alert: "Please register your household first."
      return
    end

    pickups = household.pickups.order(created_at: :desc)
    pickups = pickups.where(status: params[:status]) if params[:status].present?
    pickups = pickups.where(pickup_type: params[:pickup_type]) if params[:pickup_type].present?

    @pagy, @pickups = pagy(pickups, items: 10)
  end

  def show
    household = current_user.household
    @pickup = household&.pickups&.find_by(id: params[:id])

    redirect_to pickups_path, alert: "Pickup not found." unless @pickup
  end
end
