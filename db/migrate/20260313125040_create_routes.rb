class CreateRoutes < ActiveRecord::Migration[8.0]
  def change
    create_table :routes do |t|
      t.string :name
      t.string :area
      t.references :agent, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
