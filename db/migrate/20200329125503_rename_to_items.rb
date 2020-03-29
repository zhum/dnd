class RenameToItems < ActiveRecord::Migration[6.0]
  def change
    change_table :armorings do |t|
      t.rename :armor_id, :item_id
    end
    change_table :weaponings do |t|
      t.rename :weapon_id, :item_id
    end
    change_table :thingings do |t|
      t.rename :thing_id, :item_id
    end
    change_table :featurings do |t|
      t.rename :feature_id, :item_id
    end
  end
end
