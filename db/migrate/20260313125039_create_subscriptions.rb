class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subscription_plan, null: false, foreign_key: true
      t.integer :status
      t.date :starts_on
      t.date :ends_on

      t.timestamps
    end
  end
end
