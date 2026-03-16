class CreatePickups < ActiveRecord::Migration[8.0]
  def change
    create_table :pickups do |t|
      t.references :household, null: false, foreign_key: true
      t.references :agent, null: false, foreign_key: { to_table: :users }
      t.references :route, null: false, foreign_key: true
      t.integer :status
      t.integer :pickup_type
      t.decimal :estimated_volume
      t.text :notes
      t.decimal :latitude
      t.decimal :longitude
      t.datetime :confirmed_at

      t.timestamps
    end
  end
end
