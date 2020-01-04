class AddWeaponProficiency < ActiveRecord::Migration[6.0]
  def change
    change_table :players do |t|
      t.integer :weapon_proficiency
    end
  end
end
