class Badge < ApplicationRecord
  has_many :user_badges, dependent: :destroy
  has_many :users, through: :user_badges

  validates :name, presence: true, uniqueness: true
  validates :criteria_type, presence: true
  validates :criteria_value, presence: true, numericality: { greater_than: 0 }

  CATEGORIES = %w[recycling composting reduction consistency community].freeze

  validates :category, inclusion: { in: CATEGORIES }, allow_blank: true

  scope :by_category, ->(cat) { where(category: cat) }

  def self.seed_defaults!
    [
      { name: "Zero Waste Week", description: "Complete a full week with zero missed pickups", icon: "eco", criteria_type: "streak_days", criteria_value: 7, category: "consistency" },
      { name: "Recycling Pro", description: "Recycle 100 kg of materials", icon: "recycling", criteria_type: "recycled_kg", criteria_value: 100, category: "recycling" },
      { name: "Compost Master", description: "Compost 50 kg of organic waste", icon: "compost", criteria_type: "composted_kg", criteria_value: 50, category: "composting" },
      { name: "First Pickup", description: "Complete your first waste pickup", icon: "star", criteria_type: "total_pickups", criteria_value: 1, category: "consistency" },
      { name: "Pickup Pioneer", description: "Complete 50 waste pickups", icon: "military_tech", criteria_type: "total_pickups", criteria_value: 50, category: "consistency" },
      { name: "Eco Warrior", description: "Achieve an eco score of 50 or higher", icon: "shield", criteria_type: "eco_score", criteria_value: 50, category: "community" },
      { name: "Planet Saver", description: "Achieve an eco score of 90 or higher", icon: "public", criteria_type: "eco_score", criteria_value: 90, category: "community" },
      { name: "Waste Reducer", description: "Reduce monthly waste by 25%", icon: "trending_down", criteria_type: "waste_reduction_pct", criteria_value: 25, category: "reduction" },
      { name: "Green Streak", description: "Maintain a 30-day pickup streak", icon: "local_fire_department", criteria_type: "streak_days", criteria_value: 30, category: "consistency" },
      { name: "Community Champion", description: "Earn 500 reward points", icon: "emoji_events", criteria_type: "reward_points", criteria_value: 500, category: "community" },
    ].each do |attrs|
      Badge.find_or_create_by!(name: attrs[:name]) do |badge|
        badge.assign_attributes(attrs)
      end
    end
  end
end
