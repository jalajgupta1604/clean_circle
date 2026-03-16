class Route < ApplicationRecord
  belongs_to :agent, class_name: "User"
  has_many :households, dependent: :nullify
  has_many :pickups, dependent: :nullify

  validates :name, presence: true
  validates :area, presence: true
  validate :agent_must_have_agent_role

  private

  def agent_must_have_agent_role
    return unless agent_id.present? && agent.present?
    errors.add(:agent, "must have agent role") unless agent.agent?
  end

  public

  def today_pickups
    pickups.where(created_at: Date.current.all_day)
  end

  def completion_rate
    total = today_pickups.count
    return 0 if total.zero?
    (today_pickups.completed.count.to_f / total * 100).round(1)
  end
end
