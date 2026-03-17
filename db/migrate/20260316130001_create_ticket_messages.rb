class CreateTicketMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :ticket_messages do |t|
      t.references :support_ticket, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.boolean :from_admin, default: false
      t.timestamps
    end
  end
end
