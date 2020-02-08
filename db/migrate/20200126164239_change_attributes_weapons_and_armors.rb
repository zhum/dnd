class ChangeAttributesWeaponsAndArmors < ActiveRecord::Migration[6.0]
  def change
    change_table :armors do |t|
      t.remove :is_fencing
      t.remove :is_universal
      t.remove :is_twohand
      t.remove :is_throwable
    end

    change_table :weapons do |t|
      t.boolean :is_fencing, default: false
      t.boolean :is_universal, default: false
      t.boolean :is_twohand, default: false
      t.boolean :is_throwable, default: false
    end
  end
end
