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

  def new
    @household = current_user.household

    unless @household
      redirect_to new_household_path, alert: "Please register your household first."
      return
    end

    @subscription = current_user.subscriptions.active
                                .where("starts_on <= ? AND ends_on >= ?", Date.current, Date.current)
                                .first

    unless @subscription
      redirect_to subscriptions_path, alert: "You need an active subscription to request a pickup."
      return
    end
  end

  def create
    household = current_user.household

    unless household
      redirect_to new_household_path, alert: "Please register your household first."
      return
    end

    subscription = current_user.subscriptions.active
                               .where("starts_on <= ? AND ends_on >= ?", Date.current, Date.current)
                               .first

    unless subscription
      redirect_to subscriptions_path, alert: "You need an active subscription to request a pickup."
      return
    end

    # Check if on-demand pickup already requested today
    if household.pickups.where(created_at: Date.current.all_day, pickup_type: :on_demand).exists?
      redirect_to pickups_path, alert: "You already have an on-demand pickup request for today."
      return
    end

    route = household.route
    pickup = household.pickups.create!(
      agent: route.agent,
      route: route,
      status: :scheduled,
      pickup_type: :on_demand,
      estimated_volume: subscription.subscription_plan.bucket_size,
      notes: params[:notes]
    )

    redirect_to pickup_path(pickup), notice: "On-demand pickup requested successfully!"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to new_pickup_path, alert: e.message
  end
end
