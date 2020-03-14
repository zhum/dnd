class AddFighterIndexToFight < ActiveRecord::Migration[6.0]
  def change
    change_table :fights do |t|
      t.integer :fighter_index
    end
  end
end
