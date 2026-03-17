class CreateReportAutomations < ActiveRecord::Migration[8.0]
  def change
    create_table :report_automations do |t|
      t.string :name, null: false
      t.string :report_type, null: false
      t.string :schedule, null: false, default: "monthly"
      t.string :format, null: false, default: "pdf"
      t.text :recipients
      t.string :status, null: false, default: "active"
      t.datetime :last_run_at
      t.datetime :next_run_at
      t.jsonb :branding_settings, default: {}

      t.timestamps
    end

    add_index :report_automations, :status
    add_index :report_automations, :next_run_at
  end
end
