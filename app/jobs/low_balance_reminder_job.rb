class LowBalanceReminderJob < ApplicationJob
  queue_as :default

  def perform
    User.joins(:subscriptions, :wallet)
        .where(subscriptions: { status: :active })
        .where("subscriptions.starts_on <= ? AND subscriptions.ends_on >= ?", Date.current, Date.current)
        .distinct
        .find_each do |user|
      subscription = user.active_subscription
      next unless subscription

      per_pickup_cost = (subscription.subscription_plan.price / 30.0).round(2)
      next unless user.wallet.balance < per_pickup_cost

      # Skip if reminder already sent in last 3 days
      next if user.notifications.where(notification_type: :low_balance)
                  .where("created_at >= ?", 3.days.ago).exists?

      Notification.create!(
        user: user,
        title: "Low Wallet Balance",
        body: "Your wallet balance is below the per-pickup cost. Please recharge to avoid service interruption.",
        notification_type: :low_balance
      )
    end
  end
end
