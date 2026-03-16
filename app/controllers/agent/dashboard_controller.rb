module Agent
  class DashboardController < BaseController
    def index
      today_pickups = Pickup.where(agent: current_user, created_at: Date.current.all_day)

      @total_today = today_pickups.count
      @completed_today = today_pickups.where(status: :completed).count
      @pending_today = today_pickups.where(status: %i[scheduled in_progress]).count
      @missed_today = today_pickups.where(status: :missed).count

      @routes = current_user.assigned_routes.order(:name)
    end
  end
end
