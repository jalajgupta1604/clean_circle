module Agent
  class RoutesController < BaseController
    before_action :set_route, only: :show

    def index
      @routes = current_user.assigned_routes.order(:name)
    end

    def show
      @households = @route.households
                          .includes(:pickups)
                          .order(:building_name, :unit_number)

      @household_map_data = @households.map do |household|
        today_pickup = household.pickups.find_by(created_at: Date.current.all_day)
        {
          id: household.id,
          address: household.address,
          lat: household.latitude&.to_f,
          lng: household.longitude&.to_f,
          pickup_status: today_pickup&.status
        }
      end
    end

    private

    def set_route
      @route = current_user.assigned_routes.find(params[:id])
    end
  end
end
