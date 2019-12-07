class AddPowerToArmor < ActiveRecord::Migration[6.0]
  def change
    change_table :armors do |t|
      t.integer :power
      t.integer :max_add_sleight
    end
  end
end
