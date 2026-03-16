module Admin
  class DashboardController < BaseController
    def index
      @total_users = User.where(role: :customer).count
      @total_agents = User.where(role: :agent).count
      @total_households = Household.count

      today_pickups = Pickup.where(created_at: Date.current.all_day)
      @today_pickups = today_pickups.count
      @completion_rate = @today_pickups > 0 ? (today_pickups.where(status: :completed).count * 100.0 / @today_pickups).round(1) : 0

      @monthly_revenue = WalletTransaction.where(transaction_type: :credit)
                                          .where(created_at: Date.current.all_month)
                                          .sum(:amount)

      # Pickup trend for chart (last 30 days)
      @pickup_trend = {}
      (29.downto(0)).each do |days_ago|
        day = days_ago.days.ago.to_date
        @pickup_trend[day.strftime("%b %d")] = Pickup.where(created_at: day.all_day).count
      end

      @recent_pickups = Pickup.includes(:household, :agent, :route).order(created_at: :desc).limit(10)
    end
  end
end
