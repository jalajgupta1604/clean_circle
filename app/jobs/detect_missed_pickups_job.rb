class DetectMissedPickupsJob < ApplicationJob
  queue_as :default

  def perform
    yesterday = Date.yesterday

    Pickup.where(status: :scheduled, created_at: yesterday.all_day).find_each do |pickup|
      pickup.update!(status: :missed)
    end
  end
end
