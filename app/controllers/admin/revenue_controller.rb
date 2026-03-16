module Admin
  class RevenueController < BaseController
    def index
      credit_transactions = WalletTransaction.where(transaction_type: :credit)

      @total_revenue = credit_transactions.sum(:amount)
      @this_month_revenue = credit_transactions
                              .where(created_at: Date.current.all_month)
                              .sum(:amount)
      @active_subscribers = Subscription.where(status: :active).count

      # Monthly breakdown for chart
      @monthly_revenue = {}
      (0..11).each do |months_ago|
        month_start = months_ago.months.ago.beginning_of_month
        month_end = months_ago.months.ago.end_of_month
        label = month_start.strftime("%b %Y")
        @monthly_revenue[label] = credit_transactions.where(created_at: month_start..month_end).sum(:amount)
      end
      @monthly_revenue = @monthly_revenue.reverse_each.to_h

      # Plan-wise revenue
      @plan_revenue = {}
      SubscriptionPlan.all.each do |plan|
        subs = plan.subscriptions.where(status: :active)
        @plan_revenue[plan.name] = {
          subscribers: subs.count,
          revenue: plan.price * subs.count
        }
      end
    end
  end
end
