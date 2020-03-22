class AddNameToFightGroup < ActiveRecord::Migration[6.0]
  def change
    change_table :fight_groups do |t|
      t.string :name
    end
  end
end
