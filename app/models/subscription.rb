class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :subscription_plan

  enum :status, { active: 0, paused: 1, cancelled: 2, expired: 3 }

  validates :starts_on, presence: true
  validates :ends_on, presence: true
  validate :no_overlapping_active_subscription, on: :create

  scope :current, -> { where(status: :active).where("starts_on <= ? AND ends_on >= ?", Date.current, Date.current) }
  scope :expiring_soon, -> { active.where("ends_on <= ?", 3.days.from_now) }

  def expired?
    ends_on < Date.current
  end

  def days_remaining
    return 0 if expired? || cancelled?
    [(ends_on - Date.current).to_i, 0].max
  end

  private

  def no_overlapping_active_subscription
    return unless user
    if user.subscriptions.active.where("starts_on <= ? AND ends_on >= ?", ends_on, starts_on).exists?
      errors.add(:base, "You already have an active subscription for this period")
    end
  end
end
