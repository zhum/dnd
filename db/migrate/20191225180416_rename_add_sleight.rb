class RenameAddSleight < ActiveRecord::Migration[6.0]
  def change
    change_table :armors do |t|
      t.remove :add_sleight
      t.integer :max_dexterity
    end
  end
end
