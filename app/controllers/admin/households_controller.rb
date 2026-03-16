module Admin
  class HouseholdsController < BaseController
    def index
      scope = Household.includes(:user, :route)
      scope = scope.where(route_id: params[:route_id])                                           if params[:route_id].present?
      scope = scope.where("address ILIKE :q OR building_name ILIKE :q", q: "%#{params[:q]}%")    if params[:q].present?
      @pagy, @households = pagy(scope.order(created_at: :desc))
    end

    def show
      @household = Household.includes(:user, :route).find(params[:id])
      @pickups   = @household.pickups.order(created_at: :desc).limit(20)
    end
  end
end
