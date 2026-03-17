class CreateSupportTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :support_tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :pickup, foreign_key: true
      t.string :ticket_number, null: false
      t.string :category, null: false
      t.string :status, default: "submitted"
      t.text :description
      t.text :admin_notes
      t.datetime :resolved_at
      t.timestamps
    end
    add_index :support_tickets, :ticket_number, unique: true
    add_index :support_tickets, :status
  end
end
