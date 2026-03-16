class ExpireSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform
    Subscription.active.where("ends_on < ?", Date.current).find_each do |subscription|
      subscription.update!(status: :expired)

      Notification.create!(
        user: subscription.user,
        title: "Subscription Expired",
        body: "Your #{subscription.subscription_plan.name} plan has expired. Please renew to continue service.",
        notification_type: :general
      )
    end
  end
end
