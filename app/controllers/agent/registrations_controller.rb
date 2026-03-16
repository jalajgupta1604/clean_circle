module Agent
  class RegistrationsController < ApplicationController
    skip_before_action :authenticate_user!
    layout "application"

    def new
      redirect_to root_path, notice: "You are already signed in." if user_signed_in?
      @user = User.new
    end

    def create
      @user = User.new(agent_params)
      @user.role = :agent

      if @user.save
        sign_in(@user)
        redirect_to agent_root_path, notice: "Welcome to CleanCircle Agent!"
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def agent_params
      params.require(:user).permit(:name, :email, :phone, :address, :password, :password_confirmation)
    end
  end
end
