module Agent
  class PerformanceController < BaseController
    def index
      agent_pickups = Pickup.where(agent: current_user)

      # Today's stats
      today = agent_pickups.where(created_at: Date.current.all_day)
      @today_stats = {
        total: today.count,
        completed: today.completed.count,
        missed: today.missed.count,
        pending: today.where(status: %i[scheduled in_progress]).count,
        completion_rate: today.count > 0 ? (today.completed.count.to_f / today.count * 100).round(1) : 0
      }

      # Weekly stats
      week_range = Date.current.beginning_of_week..Date.current.end_of_week
      weekly = agent_pickups.where(created_at: week_range.first.all_day.first..week_range.last.end_of_day)
      @weekly_stats = {
        total: weekly.count,
        completed: weekly.completed.count,
        missed: weekly.missed.count
      }

      # Monthly stats
      monthly = agent_pickups.where(created_at: Date.current.all_month)
      @monthly_stats = {
        total: monthly.count,
        completed: monthly.completed.count,
        missed: monthly.missed.count
      }

      # Daily history (last 7 days)
      @daily_history = {}
      7.times do |i|
        date = Date.current - (6 - i).days
        day_pickups = agent_pickups.where(created_at: date.all_day)
        @daily_history[date.strftime("%a %m/%d")] = {
          completed: day_pickups.completed.count,
          missed: day_pickups.missed.count,
          total: day_pickups.count
        }
      end

      # Chart data for Chartkick
      @chart_completed = @daily_history.transform_values { |v| v[:completed] }
      @chart_missed = @daily_history.transform_values { |v| v[:missed] }

      # Route performance
      @route_performance = current_user.assigned_routes.order(:name).map do |route|
        route_pickups = agent_pickups.where(route: route)
        total = route_pickups.count
        completed = route_pickups.completed.count
        missed = route_pickups.missed.count
        {
          name: route.name,
          area: route.area,
          total: total,
          completed: completed,
          missed: missed,
          completion_rate: total > 0 ? (completed.to_f / total * 100).round(1) : 0
        }
      end

      # Streak: consecutive days with 100% completion (looking back from yesterday)
      @streak = 0
      date = Date.current - 1.day
      loop do
        day_pickups = agent_pickups.where(created_at: date.all_day)
        day_total = day_pickups.count
        break if day_total == 0
        day_completed = day_pickups.completed.count
        break unless day_completed == day_total

        @streak += 1
        date -= 1.day
      end

      # Average pickups per day this month
      days_in_month = [Date.current.day, 1].max
      @avg_pickups_per_day = (monthly.completed.count.to_f / days_in_month).round(1)

      # Performance tips
      @tips = generate_tips
    end

    private

    def generate_tips
      tips = []

      if @today_stats[:completion_rate] == 100 && @today_stats[:total] > 0
        tips << { type: :success, message: "Great job! 100% completion today!" }
      elsif @today_stats[:missed] > 0
        tips << { type: :warning, message: "You missed #{@today_stats[:missed]} pickup#{'s' if @today_stats[:missed] > 1} today. Try to complete all remaining pickups." }
      end

      if @today_stats[:pending] > 0
        tips << { type: :info, message: "You have #{@today_stats[:pending]} pending pickup#{'s' if @today_stats[:pending] > 1} remaining today." }
      end

      if @streak >= 3
        tips << { type: :success, message: "You're on a #{@streak}-day perfect streak! Keep it up!" }
      end

      yesterday_data = @daily_history.values[-2]
      if yesterday_data && yesterday_data[:missed] > 0
        tips << { type: :warning, message: "You missed #{yesterday_data[:missed]} pickup#{'s' if yesterday_data[:missed] > 1} yesterday. Let's do better today!" }
      end

      if @avg_pickups_per_day >= 10
        tips << { type: :success, message: "Averaging #{@avg_pickups_per_day} pickups/day this month - excellent productivity!" }
      end

      tips << { type: :info, message: "Complete all pickups today to build your streak!" } if tips.empty?

      tips
    end
  end
end
