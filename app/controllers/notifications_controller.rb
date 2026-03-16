class NotificationsController < ApplicationController
  before_action :require_customer!

  def index
    @pagy, @notifications = pagy(
      current_user.notifications.order(created_at: :desc),
      items: 20
    )
    @unread_count = current_user.notifications.where(read_at: nil).count
  end

  def mark_read
    notification = current_user.notifications.find(params[:id])
    notification.read!

    respond_to do |format|
      format.html { redirect_to notifications_path, notice: "Notification marked as read." }
      format.turbo_stream { render turbo_stream: turbo_stream.replace(notification) }
    end
  end

  def mark_all_read
    current_user.notifications.where(read_at: nil).update_all(read_at: Time.current)

    respond_to do |format|
      format.html { redirect_to notifications_path, notice: "All notifications marked as read." }
      format.turbo_stream { redirect_to notifications_path, notice: "All notifications marked as read." }
    end
  end
end
