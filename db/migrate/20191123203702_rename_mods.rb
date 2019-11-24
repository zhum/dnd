class RenameMods < ActiveRecord::Migration[6.0]
  def change
    change_table :players do |t|
      t.rename :dexterity, :mod_dexterity
      t.rename :constitution, :mod_constitution
      t.rename :intellegence, :mod_intellegence
      t.rename :wisdom, :mod_wisdom
      t.rename :charisma, :mod_charisma
    end
  end
end
