class CreateBadges < ActiveRecord::Migration[8.0]
  def change
    create_table :badges do |t|
      t.string :name, null: false
      t.text :description
      t.string :icon
      t.string :criteria_type
      t.integer :criteria_value
      t.string :category

      t.timestamps
    end

    create_table :user_badges do |t|
      t.references :user, null: false, foreign_key: true
      t.references :badge, null: false, foreign_key: true
      t.datetime :earned_at, null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.timestamps
    end

    add_index :user_badges, [:user_id, :badge_id], unique: true
  end
end
