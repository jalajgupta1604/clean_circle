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
      @subscription = @household.user&.active_subscription
      @subscription_plans = SubscriptionPlan.active.order(:price)
      @wallet = @household.user&.wallet
    end

    def bulk_update
      household_ids = params[:household_ids]
      plan_id = params[:subscription_plan_id]

      if household_ids.blank?
        redirect_to admin_households_path, alert: "No households selected." and return
      end

      unless plan_id.present?
        redirect_to admin_households_path, alert: "No subscription plan selected." and return
      end

      plan = SubscriptionPlan.find(plan_id)
      households = Household.where(id: household_ids)
      updated_count = 0

      households.each do |household|
        user = household.user
        next unless user

        active_sub = user.active_subscription
        if active_sub
          active_sub.update!(subscription_plan: plan)
        else
          user.subscriptions.create!(
            subscription_plan: plan,
            status: :active,
            started_at: Time.current
          )
        end
        updated_count += 1
      end

      redirect_to admin_households_path, notice: "Successfully updated #{updated_count} household(s) to the #{plan.name} plan."
    end

    def adjust_wallet
      @household = Household.find(params[:id])
      wallet = @household.user&.wallet

      unless wallet
        redirect_to admin_household_path(@household), alert: "No wallet found for this household." and return
      end

      amount = params[:amount].to_f
      description = params[:description].presence || "Admin adjustment"

      if amount <= 0
        redirect_to admin_household_path(@household), alert: "Amount must be greater than zero." and return
      end

      begin
        if params[:transaction_type] == "credit"
          wallet.credit!(amount, description: description)
          redirect_to admin_household_path(@household), notice: "Successfully credited #{ActionController::Base.helpers.number_to_currency(amount)} to wallet."
        elsif params[:transaction_type] == "debit"
          wallet.debit!(amount, description: description)
          redirect_to admin_household_path(@household), notice: "Successfully debited #{ActionController::Base.helpers.number_to_currency(amount)} from wallet."
        else
          redirect_to admin_household_path(@household), alert: "Invalid transaction type."
        end
      rescue Wallet::InsufficientBalanceError
        redirect_to admin_household_path(@household), alert: "Insufficient wallet balance for this debit."
      end
    end
  end
end
