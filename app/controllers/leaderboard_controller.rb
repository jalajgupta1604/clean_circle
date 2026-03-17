class LeaderboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @top_households = Household.joins(:user)
                               .select("households.*, users.eco_score as top_eco_score, users.reward_points as total_points")
                               .order("top_eco_score DESC")
                               .limit(10)

    @current_rank = if current_user.household
                      Household.joins(:user)
                               .where("users.eco_score > ?", current_user.eco_score)
                               .count + 1
                    else
                      0
                    end

    @eco_score = current_user.eco_score
    @reward_points = current_user.reward_points
    @total_households = Household.count
    @completed_pickups = current_user.household&.pickups&.where(status: "completed")&.count || 0
    @pickups_this_month = current_user.household&.pickups&.where(created_at: Date.current.beginning_of_month.beginning_of_day..Date.current.end_of_day)&.count || 0
    @co2_saved = (@completed_pickups * 2.5).round(1)
  end
end
