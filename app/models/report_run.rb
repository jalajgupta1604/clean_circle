class ReportRun < ApplicationRecord
  belongs_to :report_automation

  STATUSES = %w[pending running completed failed].freeze

  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }
  scope :recent, -> { order(created_at: :desc) }

  def duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end

  def completed?
    status == "completed"
  end

  def failed?
    status == "failed"
  end
end
