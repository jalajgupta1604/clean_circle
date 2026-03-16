class WalletsController < ApplicationController
  before_action :require_customer!

  def show
    @wallet = current_user.wallet || current_user.create_wallet(balance: 0)
    @pagy, @transactions = pagy(@wallet.wallet_transactions.order(created_at: :desc), items: 15)
  end

  def recharge
    amount = params[:amount].to_d

    if amount <= 0
      redirect_to wallet_path, alert: "Please enter a valid amount."
      return
    end

    wallet = current_user.wallet || current_user.create_wallet(balance: 0)
    wallet.credit!(amount, description: "Wallet recharge")

    redirect_to wallet_path, notice: "Wallet recharged with #{ActionController::Base.helpers.number_to_currency(amount, unit: '₹')} successfully."
  end
end
