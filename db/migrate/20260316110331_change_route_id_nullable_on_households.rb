class ChangeRouteIdNullableOnHouseholds < ActiveRecord::Migration[8.0]
  def change
    change_column_null :households, :route_id, true
  end
end
