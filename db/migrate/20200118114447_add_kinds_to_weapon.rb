class AddKindsToWeapon < ActiveRecord::Migration[6.0]
  def change
    change_table :weapons do |t|
      t.boolean :is_light, default: false
      t.boolean :is_heavy, default: false
      t.boolean :is_fencing, default: false
      t.boolean :is_universal, default: false
      t.boolean :is_twohand, default: false
      t.boolean :is_throwable, default: false
    end
  end
end
