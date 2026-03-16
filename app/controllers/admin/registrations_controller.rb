module Admin
  class RegistrationsController < ApplicationController
    skip_before_action :authenticate_user!
    layout "application"

    ADMIN_INVITE_CODE = ENV.fetch("ADMIN_INVITE_CODE", "CLEANCIRCLE2026")

    def new
      redirect_to root_path, notice: "You are already signed in." if user_signed_in?
      @user = User.new
    end

    def create
      unless params[:invite_code] == ADMIN_INVITE_CODE
        @user = User.new(admin_params)
        @user.errors.add(:base, "Invalid invite code")
        return render :new, status: :unprocessable_entity
      end

      @user = User.new(admin_params)
      @user.role = :admin

      if @user.save
        sign_in(@user)
        redirect_to admin_root_path, notice: "Welcome to CleanCircle Admin!"
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def admin_params
      params.require(:user).permit(:name, :email, :phone, :address, :password, :password_confirmation)
    end
  end
end
