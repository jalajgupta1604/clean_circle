class CreateWalletTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :wallet_transactions do |t|
      t.references :wallet, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :transaction_type
      t.string :description
      t.string :reference_id

      t.timestamps
    end
  end
end
