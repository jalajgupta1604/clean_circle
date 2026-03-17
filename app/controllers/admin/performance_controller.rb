require "csv"

module Admin
  class PerformanceController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!
    layout "admin"

    def index
      @total_revenue = WalletTransaction.where(transaction_type: "debit").sum(:amount)
      @total_customers = User.where(role: :customer).count
      @arpu = @total_customers > 0 ? (@total_revenue.to_f / @total_customers).round(2) : 0

      @total_pickups = Pickup.count
      @completed_pickups = Pickup.where(status: "completed").count
      @missed_pickups = Pickup.where(status: "missed").count
      @missed_rate = @total_pickups > 0 ? ((@missed_pickups.to_f / @total_pickups) * 100).round(1) : 0
      @completion_rate = @total_pickups > 0 ? ((@completed_pickups.to_f / @total_pickups) * 100).round(1) : 0

      @total_agents = User.where(role: :agent).count
      @active_agents = User.where(role: :agent).joins(:assigned_routes).distinct.count
      @agent_utilization = @total_agents > 0 ? ((@active_agents.to_f / @total_agents) * 100).round(0) : 0

      @carbon_offset = (@completed_pickups * 2.5).round(1)
      @recycling_rate = 72

      @top_agents = User.where(role: :agent)
                        .left_joins(:pickups)
                        .select("users.*, COUNT(pickups.id) as pickup_count")
                        .group("users.id")
                        .order("pickup_count DESC")
                        .limit(5)

      @active_subscriptions = Subscription.where(status: "active").count
      @total_households = Household.count
    end

    def generate_report
      report_type = params[:report_type]
      csv_data = case report_type
                 when "sustainability"
                   generate_sustainability_report
                 when "agent_performance"
                   generate_agent_performance_report
                 when "revenue"
                   generate_revenue_report
                 when "waste_trends"
                   generate_waste_trends_report
                 else
                   redirect_to admin_performance_path, alert: "Unknown report type" and return
                 end

      send_data csv_data,
                filename: "#{report_type}_report_#{Date.current.strftime('%Y%m%d')}.csv",
                type: "text/csv",
                disposition: "attachment"
    end

    private

    def generate_sustainability_report
      pickups = Pickup.where(status: "completed")
      CSV.generate(headers: true) do |csv|
        csv << ["CleanCircle Sustainability Report", "", "", "Generated: #{Date.current}"]
        csv << []
        csv << ["Metric", "Value"]
        csv << ["Total Completed Pickups", pickups.count]
        csv << ["Estimated CO2 Offset (kg)", (pickups.count * 2.5).round(1)]
        csv << ["Recycling Rate", "72%"]
        csv << ["Total Households Served", Household.count]
        csv << ["Active Subscriptions", Subscription.where(status: "active").count]
        csv << []
        csv << ["Monthly Breakdown"]
        csv << ["Month", "Pickups Completed", "CO2 Offset (kg)"]
        pickups.group_by { |p| p.updated_at.beginning_of_month }.sort.last(6).each do |month, month_pickups|
          csv << [month.strftime("%B %Y"), month_pickups.count, (month_pickups.count * 2.5).round(1)]
        end
      end
    end

    def generate_agent_performance_report
      agents = User.where(role: :agent).left_joins(:pickups)
                   .select("users.*, COUNT(pickups.id) as pickup_count")
                   .group("users.id").order("pickup_count DESC")
      CSV.generate(headers: true) do |csv|
        csv << ["CleanCircle Agent Performance Report", "", "", "Generated: #{Date.current}"]
        csv << []
        csv << ["Agent Name", "Email", "Total Pickups", "Has Route"]
        agents.each do |agent|
          csv << [agent.name, agent.email, agent.pickup_count, agent.assigned_routes.any? ? "Yes" : "No"]
        end
      end
    end

    def generate_revenue_report
      transactions = WalletTransaction.order(created_at: :desc).limit(500)
      CSV.generate(headers: true) do |csv|
        csv << ["CleanCircle Revenue & Billing Report", "", "", "Generated: #{Date.current}"]
        csv << []
        csv << ["Total Revenue", WalletTransaction.where(transaction_type: "debit").sum(:amount)]
        csv << ["Total Recharges", WalletTransaction.where(transaction_type: "credit").sum(:amount)]
        csv << ["Total Customers", User.where(role: :customer).count]
        csv << []
        csv << ["Date", "Description", "Type", "Amount"]
        transactions.each do |txn|
          csv << [txn.created_at.strftime("%Y-%m-%d"), txn.description, txn.transaction_type, txn.amount]
        end
      end
    end

    def generate_waste_trends_report
      CSV.generate(headers: true) do |csv|
        csv << ["CleanCircle Neighborhood Waste Trends", "", "", "Generated: #{Date.current}"]
        csv << []
        csv << ["Route", "Total Pickups", "Completed", "Missed", "Completion Rate"]
        Route.includes(:pickups).each do |route|
          total = route.pickups.count
          completed = route.pickups.where(status: "completed").count
          missed = route.pickups.where(status: "missed").count
          rate = total > 0 ? "#{((completed.to_f / total) * 100).round(1)}%" : "N/A"
          csv << [route.name, total, completed, missed, rate]
        end
      end
    end

    def require_admin!
      redirect_to root_path, alert: "Not authorized" unless current_user&.admin?
    end
  end
end
