module Admin
  class SubscriptionsController < BaseController
    def index
      scope = Subscription.includes(:user, :subscription_plan)
      scope = scope.where(status: params[:status])                       if params[:status].present?
      scope = scope.where(subscription_plan_id: params[:plan_id])        if params[:plan_id].present?
      @pagy, @subscriptions = pagy(scope.order(created_at: :desc))
    end

    def show
      @subscription = Subscription.includes(:user, :subscription_plan).find(params[:id])
    end
  end
end
