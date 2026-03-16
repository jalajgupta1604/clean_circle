class SubscriptionPlan < ApplicationRecord
  has_many :subscriptions, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :bucket_size, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }
end
