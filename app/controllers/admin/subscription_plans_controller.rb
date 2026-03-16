module Admin
  class SubscriptionPlansController < BaseController
    before_action :set_plan, only: %i[show edit update destroy]

    def index
      scope = SubscriptionPlan.all
      scope = scope.where(active: true) if params[:active] == "true"
      @pagy, @plans = pagy(scope.order(created_at: :desc))
    end

    def show
      @subscriptions_count = @plan.subscriptions.count
    end

    def new
      @plan = SubscriptionPlan.new
    end

    def create
      @plan = SubscriptionPlan.new(plan_params)

      if @plan.save
        redirect_to admin_subscription_plan_path(@plan), notice: "Subscription plan was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @plan.update(plan_params)
        redirect_to admin_subscription_plan_path(@plan), notice: "Subscription plan was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @plan.destroy
      redirect_to admin_subscription_plans_path, notice: "Subscription plan was successfully deleted."
    end

    private

    def set_plan
      @plan = SubscriptionPlan.find(params[:id])
    end

    def plan_params
      params.require(:subscription_plan).permit(:name, :bucket_size, :price, :description, :active)
    end
  end
end
