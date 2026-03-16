module Admin
  class AgentsController < BaseController
    before_action :set_agent, only: %i[show edit update]

    def index
      scope = User.where(role: :agent)
      scope = scope.where("name ILIKE :q OR email ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
      @pagy, @agents = pagy(scope.order(created_at: :desc))
    end

    def show
      @routes  = @agent.assigned_routes.includes(:households)
      @pickups = @agent.pickups.order(created_at: :desc).limit(20)
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
