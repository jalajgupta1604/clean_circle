class CreateWallets < ActiveRecord::Migration[8.0]
  def change
    create_table :wallets do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :balance, precision: 10, scale: 2, default: 0.0, null: false

      t.timestamps
    end
  end
end
