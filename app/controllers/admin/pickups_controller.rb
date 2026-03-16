module Admin
  class PickupsController < BaseController
    def index
      scope = Pickup.includes(:household, :agent, :route)
      scope = scope.where(status: params[:status])                          if params[:status].present?
      scope = scope.where(route_id: params[:route_id])                      if params[:route_id].present?
      scope = scope.where(created_at: Date.parse(params[:date]).all_day)    if params[:date].present?
      @pagy, @pickups = pagy(scope.order(created_at: :desc))
    end

    def show
      @pickup = Pickup.includes(:household, :agent, :route).find(params[:id])
    end

    def new
      @routes = Route.includes(:agent).all
    end

    def create
      route = Route.find(params[:route_id])
      date = params[:date].present? ? Date.parse(params[:date]) : Date.current
      households = route.households.joins(user: :subscriptions)
                        .where(subscriptions: { status: :active })
                        .where("subscriptions.starts_on <= ? AND subscriptions.ends_on >= ?", date, date)
                        .distinct

      created_count = 0
      households.each do |household|
        next if household.pickups.where(created_at: date.all_day, pickup_type: :regular).exists?

        plan = household.user.subscriptions.active
                        .where("starts_on <= ? AND ends_on >= ?", date, date)
                        .first&.subscription_plan

        household.pickups.create!(
          agent: route.agent,
          route: route,
          status: :scheduled,
          pickup_type: :regular,
          estimated_volume: plan&.bucket_size || 10
        )
        created_count += 1
      end

      redirect_to admin_pickups_path, notice: "#{created_count} pickups scheduled for #{route.name} on #{date.strftime('%b %d, %Y')}."
    rescue ActiveRecord::RecordNotFound
      redirect_to new_admin_pickup_path, alert: "Route not found."
    end

    def schedule
      @routes = Route.includes(:agent, :households).all
    end

    def batch_create
      date = params[:date].present? ? Date.parse(params[:date]) : Date.current
      route_ids = params[:route_ids] || []

      if route_ids.empty?
        redirect_to schedule_admin_pickups_path, alert: "Please select at least one route."
        return
      end

      total_created = 0
      Route.where(id: route_ids).includes(:agent, :households).find_each do |route|
        households = route.households.joins(user: :subscriptions)
                          .where(subscriptions: { status: :active })
                          .where("subscriptions.starts_on <= ? AND subscriptions.ends_on >= ?", date, date)
                          .distinct

        households.each do |household|
          next if household.pickups.where(created_at: date.all_day, pickup_type: :regular).exists?

          plan = household.user.subscriptions.active
                          .where("starts_on <= ? AND ends_on >= ?", date, date)
                          .first&.subscription_plan

          household.pickups.create!(
            agent: route.agent,
            route: route,
            status: :scheduled,
            pickup_type: :regular,
            estimated_volume: plan&.bucket_size || 10
          )
          total_created += 1
        end
      end

      redirect_to admin_pickups_path, notice: "#{total_created} pickups scheduled across #{route_ids.size} routes for #{date.strftime('%b %d, %Y')}."
    end
  end
end
