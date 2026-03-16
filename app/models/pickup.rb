class Pickup < ApplicationRecord
  belongs_to :household
  belongs_to :agent, class_name: "User"
  belongs_to :route

  enum :status, { scheduled: 0, in_progress: 1, completed: 2, missed: 3, cancelled: 4 }
  enum :pickup_type, { regular: 0, on_demand: 1 }

  validates :status, presence: true

  scope :today, -> { where(created_at: Date.current.all_day) }
  scope :this_month, -> { where(created_at: Date.current.all_month) }

  after_update :deduct_wallet_on_completion
  after_create :send_scheduled_notification
  after_update :send_completion_notification, if: :saved_change_to_status?

  def confirm!(latitude: nil, longitude: nil)
    update!(
      status: :completed,
      confirmed_at: Time.current,
      latitude: latitude,
      longitude: longitude
    )
  end

  def mark_missed!(notes: nil)
    update!(status: :missed, notes: notes)
  end

  private

  def deduct_wallet_on_completion
    return unless saved_change_to_status? && completed?
    wallet = household.user.wallet
    plan = household.user.active_subscription&.subscription_plan
    return unless plan

    per_pickup_cost = (plan.price / 30.0).round(2)
    wallet.debit!(per_pickup_cost, description: "Pickup ##{id}", reference_id: id.to_s)
  rescue Wallet::InsufficientBalanceError
    Notification.create!(
      user: household.user,
      title: "Low Wallet Balance",
      body: "Your wallet balance is insufficient. Please recharge to continue service.",
      notification_type: :low_balance
    )
  end

  def send_scheduled_notification
    Notification.create!(
      user: household.user,
      title: "Pickup Scheduled",
      body: "A waste pickup has been scheduled for your household.",
      notification_type: :pickup_scheduled
    )
  end

  def send_completion_notification
    return unless completed?
    Notification.create!(
      user: household.user,
      title: "Pickup Completed",
      body: "Your waste has been collected successfully.",
      notification_type: :pickup_confirmed
    )
  end
end
