class RewardsController < ApplicationController
  before_action :require_customer!

  def index
    current_user.calculate_eco_score!
    @eco_score = current_user.eco_score
    @eco_badge = current_user.eco_badge
    @reward_points = current_user.reward_points
    @wallet_balance = current_user.wallet&.balance || 0
    @reward_notifications = current_user.notifications.where(notification_type: :reward).order(created_at: :desc).limit(20)
    @total_pickups = current_user.household&.pickups&.completed&.count || 0
  end

  def redeem
    amount = params[:amount].to_i

    if amount < 100
      redirect_to rewards_path, alert: "Minimum 100 points required for redemption."
      return
    end

    if amount > current_user.reward_points
      redirect_to rewards_path, alert: "You don't have enough points."
      return
    end

    credit = current_user.redeem_points!(amount)
    redirect_to rewards_path, notice: "Successfully redeemed #{amount} points for #{helpers.number_to_currency(credit, unit: "\u20B9", precision: 2)} wallet credit!"
  rescue StandardError => e
    redirect_to rewards_path, alert: e.message
  end
end
