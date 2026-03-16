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
