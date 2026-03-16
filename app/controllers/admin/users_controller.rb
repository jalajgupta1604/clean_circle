module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy]

    def index
      scope = User.all
      scope = scope.where(role: params[:role]) if params[:role].present?
      scope = scope.where("name ILIKE :q OR email ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
      @pagy, @users = pagy(scope.order(created_at: :desc))
    end

    def show
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)

      if @user.save
        redirect_to admin_user_path(@user), notice: "User was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      update_attrs = user_params
      update_attrs = update_attrs.except(:password, :password_confirmation) if update_attrs[:password].blank?

      if @user.update(update_attrs)
        redirect_to admin_user_path(@user), notice: "User was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: "User was successfully deleted."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :phone, :role, :family_size, :address, :password, :password_confirmation)
    end
  end
end
