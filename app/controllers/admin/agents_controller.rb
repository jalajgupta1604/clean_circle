module Admin
  class AgentsController < BaseController
    before_action :set_agent, only: %i[show edit update assign_route]

    def index
      scope = User.where(role: :agent)
      scope = scope.where("name ILIKE :q OR email ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
      @pagy, @agents = pagy(scope.order(created_at: :desc))
    end

    def show
      @routes  = @agent.assigned_routes.includes(:households)
      @pickups = @agent.pickups.order(created_at: :desc).limit(20)
      @available_routes = Route.where(agent_id: nil).or(Route.where.not(agent_id: @agent.id)).order(:name)

      # Performance summary for current month
      month_pickups = @agent.pickups.where(created_at: Date.current.all_month)
      @month_total_pickups = month_pickups.count
      @month_completed = month_pickups.completed.count
      @month_missed = month_pickups.missed.count
      @month_completion_rate = @month_total_pickups > 0 ? (@month_completed.to_f / @month_total_pickups * 100).round(1) : 0

      # Agent active status based on recent activity (pickup in last 7 days)
      @agent_active = @agent.pickups.where("created_at >= ?", 7.days.ago).exists?
    end

    def assign_route
      route = Route.find(params[:route_id])
      route.update!(agent_id: @agent.id)
      redirect_to admin_agent_path(@agent), notice: "Route '#{route.name}' has been assigned to #{@agent.name}."
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_agent_path(@agent), alert: "Route not found."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_agent_path(@agent), alert: "Failed to assign route: #{e.message}"
    end

    def edit
    end

    def update
      if @agent.update(agent_params)
        redirect_to admin_agent_path(@agent), notice: "Agent was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_agent
      @agent = User.where(role: :agent).find(params[:id])
    end

    def agent_params
      params.require(:user).permit(:name, :email, :phone, :address)
    end
  end
end
