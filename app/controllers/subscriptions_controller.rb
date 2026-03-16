class SubscriptionsController < ApplicationController
  before_action :require_customer!

  def index
    @active_subscription = current_user.subscriptions.find_by(status: :active)
    @past_subscriptions = current_user.subscriptions.where.not(status: :active).order(created_at: :desc)
  end

  def new
    @plans = SubscriptionPlan.all.order(:price)
    @active_subscription = current_user.subscriptions.find_by(status: :active)
  end

  def create
    plan = SubscriptionPlan.find(params[:subscription_plan_id])

    existing = current_user.subscriptions.find_by(status: :active)
    if existing
      redirect_to subscriptions_path, alert: "You already have an active subscription. Please cancel it before subscribing to a new plan."
      return
    end

    wallet = current_user.wallet
    if wallet.nil? || wallet.balance < plan.price
      redirect_to new_subscription_path, alert: "Insufficient wallet balance. Please recharge your wallet."
      return
    end

    @subscription = current_user.subscriptions.build(
      subscription_plan: plan,
      status: :active,
      starts_on: Date.current,
      ends_on: Date.current + 30.days
    )

    if @subscription.save
      wallet.debit!(plan.price, description: "Subscription: #{plan.name}")
      redirect_to subscriptions_path, notice: "Successfully subscribed to #{plan.name}."
    else
      redirect_to new_subscription_path, alert: "Something went wrong. Please try again."
    end
  end
end
