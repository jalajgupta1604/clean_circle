module Admin
  class WasteAnalyticsController < BaseController
    def index
      completed_pickups = Pickup.completed

      # Summary stats
      @total_waste = completed_pickups.sum(:estimated_volume)
      @monthly_waste = completed_pickups.where(created_at: Date.current.all_month).sum(:estimated_volume)

      days_in_month = Date.current.day
      @daily_average = days_in_month > 0 ? (@monthly_waste / days_in_month).round(1) : 0

      # Waste by route
      @waste_by_route = {}
      Route.includes(:pickups).each do |route|
        route_completed = route.pickups.completed
        total = route_completed.sum(:estimated_volume)
        next if total.zero?

        count = route_completed.count
        @waste_by_route[route.name] = {
          area: route.area,
          total_waste: total,
          pickup_count: count,
          avg_per_pickup: count > 0 ? (total / count).round(1) : 0
        }
      end

      # Waste by subscription plan bucket size
      @waste_by_bucket = {}
      SubscriptionPlan.all.each do |plan|
        user_ids = plan.subscriptions.pluck(:user_id)
        household_ids = Household.where(user_id: user_ids).pluck(:id)
        volume = completed_pickups.where(household_id: household_ids).sum(:estimated_volume)
        @waste_by_bucket["#{plan.name} (#{plan.bucket_size}L)"] = volume if volume > 0
      end

      # Monthly trend (last 12 months)
      @monthly_trend = {}
      (0..11).each do |months_ago|
        month_start = months_ago.months.ago.beginning_of_month
        month_end = months_ago.months.ago.end_of_month
        label = month_start.strftime("%b %Y")
        @monthly_trend[label] = completed_pickups.where(created_at: month_start..month_end).sum(:estimated_volume)
      end
      @monthly_trend = @monthly_trend.reverse_each.to_h

      # Waste by area
      @waste_by_area = {}
      Route.all.each do |route|
        volume = route.pickups.completed.sum(:estimated_volume)
        @waste_by_area[route.area] = (@waste_by_area[route.area] || 0) + volume
      end
      @waste_by_area.reject! { |_k, v| v.zero? }

      # Top 10 households by waste volume
      @top_households = Household
        .joins(:pickups)
        .where(pickups: { status: :completed })
        .group("households.id")
        .select(
          "households.*",
          "SUM(pickups.estimated_volume) AS total_volume",
          "COUNT(pickups.id) AS pickup_count"
        )
        .order("total_volume DESC")
        .limit(10)

      # Reduction trend (month-over-month change for last 6 months)
      @reduction_trend = []
      (0..5).each do |months_ago|
        month_start = months_ago.months.ago.beginning_of_month
        month_end = months_ago.months.ago.end_of_month
        current_volume = completed_pickups.where(created_at: month_start..month_end).sum(:estimated_volume)

        prev_month_start = (months_ago + 1).months.ago.beginning_of_month
        prev_month_end = (months_ago + 1).months.ago.end_of_month
        prev_volume = completed_pickups.where(created_at: prev_month_start..prev_month_end).sum(:estimated_volume)

        change_pct = if prev_volume > 0
                       ((current_volume - prev_volume) / prev_volume * 100).round(1)
                     else
                       0.0
                     end

        @reduction_trend << {
          month: month_start.strftime("%b %Y"),
          total_waste: current_volume,
          change_pct: change_pct
        }
      end
      @reduction_trend.reverse!

      # Pickup stats
      total_pickups = Pickup.count
      completed_count = completed_pickups.count
      missed_count = Pickup.missed.count
      completion_rate = total_pickups > 0 ? (completed_count.to_f / total_pickups * 100).round(1) : 0

      @pickup_stats = {
        total: total_pickups,
        completed: completed_count,
        missed: missed_count,
        completion_rate: completion_rate
      }
    end
  end
end
