class HouseholdsController < ApplicationController
  before_action :require_customer!
  before_action :set_household, only: [:show, :edit, :update, :destroy, :qr_code]

  def index
    @household = current_user.household
    redirect_to new_household_path unless @household
  end

  def show
  end

  def new
    redirect_to household_path, notice: "You already have a household registered." if current_user.household
    @household = Household.new
  end

  def create
    @household = current_user.build_household(household_params)

    if @household.save
      redirect_to household_path, notice: "Household registered successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @household.update(household_params)
      redirect_to household_path, notice: "Household updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @household.destroy
    redirect_to root_path, notice: "Household removed."
  end

  def qr_code
    @qr_svg = @household.qr_code_svg
  end

  private

  def set_household
    @household = current_user.household
    redirect_to new_household_path, alert: "Please register your household first." unless @household
  end

  def household_params
    params.require(:household).permit(:address, :building_name, :unit_number, :latitude, :longitude)
  end
end
