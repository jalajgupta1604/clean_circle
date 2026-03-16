class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :authenticate_user!

  # allow_browser versions: :modern

  private

  def after_sign_in_path_for(resource)
    root_path
  end

  def require_customer!
    unless current_user.customer?
      redirect_to root_path, alert: "Access denied."
    end
  end
end
