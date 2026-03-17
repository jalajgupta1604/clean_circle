class EcoStatsController < ApplicationController
  before_action :authenticate_user!

  def index
    @household = current_user.household
    completed_pickups = @household ? @household.pickups.where(status: :completed) : Pickup.none

    # CO2 offset calculation (roughly 2.5 kg CO2 saved per pickup)
    total_pickups = completed_pickups.count
    @co2_offset = (total_pickups * 2.5 / 1000.0).round(1) # in tonnes

    # Trees equivalent (1 tree absorbs ~22 kg CO2/year)
    @trees_equivalent = (@co2_offset * 1000 / 22.0).round.to_i

    # Miles saved equivalent
    @miles_saved = (@co2_offset * 1000 / 0.411).round.to_i # avg car emits 0.411 kg/mile

    # Waste diverted
    @waste_diverted = completed_pickups.sum(:estimated_volume).round.to_i

    # Eco grade
    current_user.calculate_eco_score! if @household
    @eco_score = current_user.eco_score || 0
    @eco_grade = case @eco_score
                 when 90..100 then "A+"
                 when 80..89 then "A"
                 when 70..79 then "A-"
                 when 60..69 then "B+"
                 when 50..59 then "B"
                 when 40..49 then "C+"
                 when 30..39 then "C"
                 when 20..29 then "D"
                 else "F"
                 end

    # Monthly history (last 6 months)
    @monthly_data = {}
    6.downto(0) do |months_ago|
      month = months_ago.months.ago
      month_label = month.strftime("%b")
      volume = completed_pickups
        .where(confirmed_at: month.all_month)
        .sum(:estimated_volume)
      @monthly_data[month_label] = volume.round(1)
    end

    # Current month volume
    @current_month_volume = completed_pickups
      .where(confirmed_at: Time.current.all_month)
      .sum(:estimated_volume).round(1)

    # Waste trend (this vs last month)
    last_month_vol = completed_pickups
      .where(confirmed_at: 1.month.ago.all_month)
      .sum(:estimated_volume)
    this_month_vol = @current_month_volume
    @waste_trend = if last_month_vol > 0
                     change = ((this_month_vol - last_month_vol) / last_month_vol.to_f * 100).round
                     change > 0 ? "+#{change}%" : "#{change}%"
                   else
                     "N/A"
                   end

    # Badges earned
    @badges = current_user.badges.order("user_badges.earned_at DESC")
  end
end
