module Agent
  class BaseController < ApplicationController
    before_action :require_agent!
    layout "agent"

    private

    def require_agent!
      unless current_user&.agent?
        redirect_to root_path, alert: "Access denied. Agent role required."
      end
    end
  end
end
