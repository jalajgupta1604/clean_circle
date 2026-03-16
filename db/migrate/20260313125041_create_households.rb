class CreateHouseholds < ActiveRecord::Migration[8.0]
  def change
    create_table :households do |t|
      t.references :user, null: false, foreign_key: true
      t.references :route, null: false, foreign_key: true
      t.text :address
      t.string :building_name
      t.string :unit_number
      t.string :qr_code_token
      t.decimal :latitude
      t.decimal :longitude

      t.timestamps
    end
  end
end
