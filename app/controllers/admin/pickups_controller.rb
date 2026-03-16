module Admin
  class PickupsController < BaseController
    def index
      scope = Pickup.includes(:household, :agent, :route)
      scope = scope.where(status: params[:status])                          if params[:status].present?
      scope = scope.where(route_id: params[:route_id])                      if params[:route_id].present?
      scope = scope.where(created_at: Date.parse(params[:date]).all_day)    if params[:date].present?
      @pagy, @pickups = pagy(scope.order(created_at: :desc))
    end

    def show
      @pickup = Pickup.includes(:household, :agent, :route).find(params[:id])
    end
  end
end
