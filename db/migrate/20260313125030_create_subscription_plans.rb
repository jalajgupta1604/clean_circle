class CreateSubscriptionPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :subscription_plans do |t|
      t.string :name, null: false
      t.integer :bucket_size, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.text :description
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
