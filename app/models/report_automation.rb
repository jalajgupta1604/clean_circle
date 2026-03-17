class ReportAutomation < ApplicationRecord
  has_many :report_runs, dependent: :destroy

  REPORT_TYPES = %w[sustainability_audit agent_performance revenue operations].freeze
  SCHEDULES = %w[daily weekly monthly quarterly].freeze
  FORMATS = %w[pdf csv].freeze
  STATUSES = %w[active paused].freeze

  validates :name, presence: true
  validates :report_type, presence: true, inclusion: { in: REPORT_TYPES }
  validates :schedule, presence: true, inclusion: { in: SCHEDULES }
  validates :format, presence: true, inclusion: { in: FORMATS }
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :active, -> { where(status: "active") }
  scope :paused, -> { where(status: "paused") }
  scope :due, -> { active.where("next_run_at <= ?", Time.current) }

  def recipients_list
    (recipients || "").split(",").map(&:strip).reject(&:blank?)
  end

  def recipients_list=(list)
    self.recipients = Array(list).join(", ")
  end

  def active?
    status == "active"
  end

  def paused?
    status == "paused"
  end

  def toggle_status!
    update!(status: active? ? "paused" : "active")
  end

  def last_run
    report_runs.order(created_at: :desc).first
  end

  def last_run_status
    run = last_run
    return "Never run" unless run
    run.status.humanize
  end

  def calculate_next_run_at
    base = last_run_at || Time.current
    self.next_run_at = case schedule
                       when "daily" then base + 1.day
                       when "weekly" then base + 1.week
                       when "monthly" then base + 1.month
                       when "quarterly" then base + 3.months
                       else base + 1.month
                       end
  end
end
