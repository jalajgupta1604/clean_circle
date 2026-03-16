class AddEcoScoreAndRewardPointsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :eco_score, :integer, default: 0, null: false
    add_column :users, :reward_points, :integer, default: 0, null: false
  end
end
