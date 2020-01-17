class AddProficiencyToChars < ActiveRecord::Migration[6.0]
  def change
    change_table :players do |t|
      t.boolean :mod_prof_dexterity
      t.boolean :mod_prof_wisdom
      t.boolean :mod_prof_constitution
      t.boolean :mod_prof_strength
      t.boolean :mod_prof_intellegence
      t.boolean :mod_prof_charisma
    end
  end
end
