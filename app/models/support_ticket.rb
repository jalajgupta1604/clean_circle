class SupportTicket < ApplicationRecord
  belongs_to :user
  belongs_to :pickup, optional: true
  has_many :ticket_messages, dependent: :destroy

  CATEGORIES = ["Missed Pickup", "Damaged Bin", "Incomplete Collection", "Spillage", "Other"].freeze
  STATUSES = ["submitted", "under_review", "resolved"].freeze

  validates :ticket_number, presence: true, uniqueness: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :status, inclusion: { in: STATUSES }
  validates :description, presence: true

  before_validation :generate_ticket_number, on: :create

  scope :open_tickets, -> { where.not(status: "resolved") }
  scope :resolved, -> { where(status: "resolved") }

  def submitted?
    status == "submitted"
  end

  def under_review?
    status == "under_review"
  end

  def resolved?
    status == "resolved"
  end

  private

  def generate_ticket_number
    self.ticket_number ||= "CC-#{SecureRandom.random_number(10000).to_s.rjust(4, '0')}"
  end
end
