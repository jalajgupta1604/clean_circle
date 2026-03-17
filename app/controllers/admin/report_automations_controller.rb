module Admin
  class ReportAutomationsController < BaseController
    before_action :set_report_automation, only: [:show, :edit, :update, :destroy, :run, :toggle_status]

    def index
      scope = ReportAutomation.all
      scope = scope.where(status: params[:status]) if params[:status].present?
      @pagy, @report_automations = pagy(scope.order(created_at: :desc))
      @stats = {
        total: ReportAutomation.count,
        active: ReportAutomation.active.count,
        runs_this_month: ReportRun.where(created_at: Time.current.all_month).count,
        success_rate: calculate_success_rate
      }
    end

    def show
      @recent_runs = @report_automation.report_runs.recent.limit(10)
    end

    def new
      @report_automation = ReportAutomation.new
    end

    def create
      @report_automation = ReportAutomation.new(report_automation_params)
      @report_automation.calculate_next_run_at

      if @report_automation.save
        redirect_to admin_report_automations_path, notice: "Report automation created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @report_automation.update(report_automation_params)
        @report_automation.calculate_next_run_at
        @report_automation.save
        redirect_to admin_report_automations_path, notice: "Report automation updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @report_automation.destroy
      redirect_to admin_report_automations_path, notice: "Report automation deleted."
    end

    def run
      report_run = @report_automation.report_runs.create!(
        status: "running",
        started_at: Time.current
      )

      # Simulate report generation (in production this would be a background job)
      report_run.update!(
        status: "completed",
        completed_at: Time.current,
        file_path: "reports/#{@report_automation.report_type}_#{Time.current.strftime('%Y%m%d%H%M%S')}.#{@report_automation.format}"
      )

      @report_automation.update!(last_run_at: Time.current)
      @report_automation.calculate_next_run_at
      @report_automation.save!

      redirect_to admin_report_automations_path, notice: "Report '#{@report_automation.name}' generated successfully."
    rescue => e
      report_run&.update(status: "failed", error_message: e.message, completed_at: Time.current)
      redirect_to admin_report_automations_path, alert: "Report generation failed: #{e.message}"
    end

    def toggle_status
      @report_automation.toggle_status!
      redirect_to admin_report_automations_path, notice: "Report automation #{@report_automation.status}."
    end

    private

    def set_report_automation
      @report_automation = ReportAutomation.find(params[:id])
    end

    def report_automation_params
      params.require(:report_automation).permit(
        :name, :report_type, :schedule, :format, :recipients, :status, :branding_settings
      )
    end

    def calculate_success_rate
      total = ReportRun.where(created_at: Time.current.all_month).count
      return 100.0 if total == 0
      completed = ReportRun.completed.where(created_at: Time.current.all_month).count
      (completed.to_f / total * 100).round(1)
    end
  end
end
