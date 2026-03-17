module Admin
  class LiveMapController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!
    layout "admin"

    def index
      @routes = Route.includes(:agent).all
      @active_routes = @routes.select { |r| r.agent.present? }
      @total_routes = @routes.count
      @active_count = @active_routes.count

      @total_pickups_today = Pickup.where(created_at: Date.current.all_day).count
      @completed_today = Pickup.where(created_at: Date.current.all_day, status: "completed").count
      @route_efficiency = @total_pickups_today > 0 ? ((@completed_today.to_f / @total_pickups_today) * 100).round(1) : 0

      @distance_saved = (@completed_today * 1.8).round(0)
      @co2_reduction = (@completed_today * 2.5).round(1)

      @recent_activity = Pickup.includes(:route).order(updated_at: :desc).limit(15)
    end

    private

    def require_admin!
      redirect_to root_path, alert: "Not authorized" unless current_user&.admin?
    end
  end
end
