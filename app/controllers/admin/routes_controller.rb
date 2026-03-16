module Admin
  class RoutesController < BaseController
    before_action :set_route, only: %i[show edit update destroy]

    def index
      scope = Route.includes(:agent)
      scope = scope.where("name ILIKE :q OR area ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
      @pagy, @routes = pagy(scope.order(created_at: :desc))
    end

    def show
      @households = @route.households.includes(:user)
      @pickups    = @route.pickups.order(created_at: :desc).limit(20)
    end

    def new
      @route  = Route.new
      @agents = User.where(role: :agent).order(:name)
    end

    def create
      @route = Route.new(route_params)

      if @route.save
        redirect_to admin_route_path(@route), notice: "Route was successfully created."
      else
        @agents = User.where(role: :agent).order(:name)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @agents = User.where(role: :agent).order(:name)
    end

    def update
      if @route.update(route_params)
        redirect_to admin_route_path(@route), notice: "Route was successfully updated."
      else
        @agents = User.where(role: :agent).order(:name)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @route.destroy
      redirect_to admin_routes_path, notice: "Route was successfully deleted."
    end

    private

    def set_route
      @route = Route.find(params[:id])
    end

    def route_params
      params.require(:route).permit(:name, :area, :agent_id)
    end
  end
end
