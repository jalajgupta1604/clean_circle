class CreateReportRuns < ActiveRecord::Migration[8.0]
  def change
    create_table :report_runs do |t|
      t.references :report_automation, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.string :file_path
      t.text :error_message
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :report_runs, :status
  end
end
