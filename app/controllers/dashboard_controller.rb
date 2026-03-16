class DashboardController < ApplicationController
  before_action :require_customer!

  def index
    @household = current_user.household
    @wallet_balance = current_user.wallet&.balance || 0
    @subscription = current_user.active_subscription
    @total_pickups = @household&.pickups&.completed&.count || 0
    @monthly_waste = @household&.pickups&.completed
                       &.where(confirmed_at: Time.current.all_month)
                       &.sum(:estimated_volume) || 0
    @recent_pickups = @household&.pickups&.order(created_at: :desc)&.limit(5) || []
  end
end
