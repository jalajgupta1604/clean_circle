class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    redirect_to root_path if user_signed_in? && !current_user.customer?
  end
end
