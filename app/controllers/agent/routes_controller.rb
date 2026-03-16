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
    end

    private

    def set_route
      @route = current_user.assigned_routes.find(params[:id])
    end
  end
end
