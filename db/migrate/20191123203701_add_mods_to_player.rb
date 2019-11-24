class AddModsToPlayer < ActiveRecord::Migration[6.0]
  def change
    change_table :players do |t|
      t.integer :mod_strength
      t.integer :dexterity
      t.integer :constitution
      t.integer :intellegence
      t.integer :wisdom
      t.integer :charisma
    end
  end
end
