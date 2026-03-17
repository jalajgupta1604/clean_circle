class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  enum :role, { customer: 0, agent: 1, admin: 2 }

  has_one :wallet, dependent: :destroy
  has_one :household, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :assigned_routes, class_name: "Route", foreign_key: :agent_id, dependent: :nullify
  has_many :pickups, foreign_key: :agent_id, dependent: :nullify
  has_many :support_tickets, dependent: :destroy
  has_many :user_badges, dependent: :destroy
  has_many :badges, through: :user_badges

  validates :name, presence: true
  validates :phone, uniqueness: true, allow_blank: true

  before_create :generate_qr_code_token
  after_create :create_wallet!

  def active_subscription
    subscriptions.where(status: :active).order(created_at: :desc).first
  end

  # --- Rewards & Eco Score ---

  def award_points!(amount, reason)
    increment!(:reward_points, amount)
    notifications.create!(
      title: "Points Earned!",
      body: "+#{amount} reward points: #{reason}",
      notification_type: :reward
    )
  end

  def redeem_points!(amount)
    raise "Not enough points to redeem" if reward_points < amount
    raise "Minimum 100 points required" if amount < 100

    credit_amount = (amount / 100.0 * 10).round(2)

    transaction do
      decrement!(:reward_points, amount)
      wallet.credit!(credit_amount, description: "Reward redemption (#{amount} pts)")
      notifications.create!(
        title: "Points Redeemed!",
        body: "You redeemed #{amount} points for #{ActionController::Base.helpers.number_to_currency(credit_amount, unit: "\u20B9", precision: 2)} wallet credit.",
        notification_type: :reward
      )
    end

    credit_amount
  end

  def calculate_eco_score!
    score = 0
    return update!(eco_score: 0) unless household

    completed_pickups = household.pickups.completed

    # Factor 1: Total pickups completed (up to 30 points)
    total = completed_pickups.count
    score += [total, 30].min

    # Factor 2: Waste reduction trend (up to 30 points)
    last_month_waste = completed_pickups
      .where(confirmed_at: 1.month.ago.all_month)
      .sum(:estimated_volume)
    this_month_waste = completed_pickups
      .where(confirmed_at: Time.current.all_month)
      .sum(:estimated_volume)

    if last_month_waste > 0 && this_month_waste < last_month_waste
      reduction_pct = ((last_month_waste - this_month_waste) / last_month_waste.to_f * 100)
      score += [reduction_pct.round, 30].min
    elsif this_month_waste == 0 && last_month_waste == 0
      score += 0
    end

    # Factor 3: Consistency - pickups in last 30 days vs expected (up to 40 points)
    recent_pickups = completed_pickups.where("confirmed_at >= ?", 30.days.ago).count
    expected = active_subscription ? 30 : 4 # daily vs minimum
    consistency_ratio = expected > 0 ? (recent_pickups.to_f / expected) : 0
    score += [(consistency_ratio * 40).round, 40].min

    update!(eco_score: [score, 100].min)
  end

  def eco_badge
    case eco_score
    when 0..25 then "Beginner"
    when 26..50 then "Eco Warrior"
    when 51..75 then "Green Champion"
    when 76..100 then "Planet Saver"
    else "Beginner"
    end
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
    end
  end

  private

  def generate_qr_code_token
    self.qr_code_token = SecureRandom.hex(16)
  end

  def create_wallet!
    Wallet.create!(user: self, balance: 0)
  end
end
