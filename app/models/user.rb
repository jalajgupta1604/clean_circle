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

  validates :name, presence: true
  validates :phone, uniqueness: true, allow_blank: true

  before_create :generate_qr_code_token
  after_create :create_wallet!

  def active_subscription
    subscriptions.where(status: :active).order(created_at: :desc).first
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
