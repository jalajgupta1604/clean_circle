class ScheduleDailyPickupsJob < ApplicationJob
  queue_as :default

  def perform
    today = Date.current

    Household.includes(:route, user: :subscriptions).find_each do |household|
      route = household.route
      next unless route&.agent

      subscription = household.user.subscriptions.active
                              .where("starts_on <= ? AND ends_on >= ?", today, today)
                              .first
      next unless subscription

      # Skip if a regular pickup already exists for today
      next if household.pickups.where(created_at: today.all_day, pickup_type: :regular).exists?

      household.pickups.create!(
        agent: route.agent,
        route: route,
        status: :scheduled,
        pickup_type: :regular,
        estimated_volume: subscription.subscription_plan.bucket_size
      )
    end
  end
end
