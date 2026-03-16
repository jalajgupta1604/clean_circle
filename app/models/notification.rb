class Notification < ApplicationRecord
  belongs_to :user

  enum :notification_type, {
    pickup_scheduled: 0,
    pickup_confirmed: 1,
    pickup_missed: 2,
    low_balance: 3,
    reward: 4,
    general: 5
  }

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(20) }

  def read!
    update!(read_at: Time.current) if read_at.nil?
  end

  def unread?
    read_at.nil?
  end
end
