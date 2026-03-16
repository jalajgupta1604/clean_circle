class Pickup < ApplicationRecord
  class InvalidTransitionError < StandardError; end

  VALID_TRANSITIONS = {
    "scheduled"   => %w[in_progress completed missed cancelled],
    "in_progress" => %w[completed missed],
    "completed"   => [],
    "missed"      => [],
    "cancelled"   => []
  }.freeze

  belongs_to :household
  belongs_to :agent, class_name: "User", optional: true
  belongs_to :route

  enum :status, { scheduled: 0, in_progress: 1, completed: 2, missed: 3, cancelled: 4 }
  enum :pickup_type, { regular: 0, on_demand: 1 }

  validates :status, presence: true
  validates :household, presence: true
  validates :route, presence: true

  scope :today, -> { where(created_at: Date.current.all_day) }
  scope :this_month, -> { where(created_at: Date.current.all_month) }
  scope :completed, -> { where(status: :completed) }
  scope :missed, -> { where(status: :missed) }
  scope :scheduled, -> { where(status: :scheduled) }

  after_update :deduct_wallet_on_completion
  after_update :award_reward_points, if: :saved_change_to_status?
  after_create :send_scheduled_notification
  after_update :send_completion_notification, if: :saved_change_to_status?
  after_update :send_missed_notification, if: :saved_change_to_status?

  def can_transition_to?(new_status)
    VALID_TRANSITIONS.fetch(status, []).include?(new_status.to_s)
  end

  def confirm!(latitude: nil, longitude: nil)
    raise InvalidTransitionError, "Cannot complete pickup from #{status} status" unless can_transition_to?("completed")

    update!(
      status: :completed,
      confirmed_at: Time.current,
      latitude: latitude,
      longitude: longitude
    )
  end

  def mark_missed!(notes = nil)
    raise InvalidTransitionError, "Cannot mark pickup as missed from #{status} status" unless can_transition_to?("missed")

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

  def send_missed_notification
    return unless missed?
    Notification.create!(
      user: household.user,
      title: "Pickup Missed",
      body: "Your scheduled pickup was missed. We apologize for the inconvenience.",
      notification_type: :pickup_missed
    )
  end

  def award_reward_points
    return unless completed?

    points = regular? ? 10 : 5
    reason = regular? ? "Regular pickup completed" : "On-demand pickup completed"
    household.user.award_points!(points, reason)
    household.user.calculate_eco_score!
  end
end
