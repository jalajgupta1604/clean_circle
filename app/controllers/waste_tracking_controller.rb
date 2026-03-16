class WasteTrackingController < ApplicationController
  before_action :require_customer!

  def index
    household = current_user.household

    unless household
      redirect_to new_household_path, alert: "Please register your household first."
      return
    end

    completed_pickups = household.pickups.completed

    @total_waste = completed_pickups.sum(:estimated_volume).round(1)
    @total_pickups = completed_pickups.count
    @avg_per_pickup = @total_pickups > 0 ? (@total_waste / @total_pickups).round(1) : 0

    @total_pickups_count = @total_pickups

    # Monthly comparison data
    @this_month_waste = completed_pickups.where(confirmed_at: Time.current.all_month).sum(:estimated_volume).round(1)
    @last_month_waste = completed_pickups.where(confirmed_at: 1.month.ago.all_month).sum(:estimated_volume).round(1)

    # Build monthly data hash for chartkick
    @monthly_data = {}
    (0..11).each do |months_ago|
      month_start = months_ago.months.ago.beginning_of_month
      month_end = months_ago.months.ago.end_of_month
      label = month_start.strftime("%b %Y")
      volume = completed_pickups.where(confirmed_at: month_start..month_end).sum(:estimated_volume)
      @monthly_data[label] = volume.round(1)
    end
    @monthly_data = @monthly_data.reverse_each.to_h
  end
end
