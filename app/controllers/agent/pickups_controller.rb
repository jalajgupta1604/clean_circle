module Agent
  class PickupsController < BaseController
    before_action :set_route, only: [:index]
    before_action :set_pickup, only: %i[show confirm mark_missed]

    def index
      @pickups = @route.pickups
                       .includes(:household)
                       .where(agent: current_user)
                       .order(created_at: :desc)
    end

    def show; end

    def confirm
      @pickup.confirm!(
        latitude:  params[:latitude],
        longitude: params[:longitude]
      )

      redirect_to agent_pickup_path(@pickup),
                  notice: "Pickup confirmed successfully."
    rescue StandardError => e
      redirect_to agent_pickup_path(@pickup),
                  alert: "Could not confirm pickup: #{e.message}"
    end

    def mark_missed
      @pickup.mark_missed!(params[:notes])

      redirect_to agent_pickup_path(@pickup),
                  notice: "Pickup marked as missed."
    rescue StandardError => e
      redirect_to agent_pickup_path(@pickup),
                  alert: "Could not mark pickup as missed: #{e.message}"
    end

    private

    def set_route
      @route = current_user.assigned_routes.find(params[:route_id])
    end

    def set_pickup
      @pickup = current_user.pickups.find(params[:id])
      @route = @pickup.route
    end
  end
end
