class UserBadge < ApplicationRecord
  belongs_to :user
  belongs_to :badge

  validates :user_id, uniqueness: { scope: :badge_id, message: "already has this badge" }
  validates :earned_at, presence: true
end
