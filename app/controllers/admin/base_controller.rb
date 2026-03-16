module Admin
  class BaseController < ApplicationController
    include Pagy::Backend

    layout "admin"

    before_action :require_admin!

    private

    def require_admin!
      unless current_user&.admin?
        redirect_to root_path, alert: "You are not authorized to access this area."
      end
    end
  end
end
