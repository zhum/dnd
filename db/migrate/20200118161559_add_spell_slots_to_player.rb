class AddSpellSlotsToPlayer < ActiveRecord::Migration[6.0]
  def change
    change_table :players do |t|
      t.integer :spell_slots_1, default: 0
      t.integer :spell_slots_2, default: 0
      t.integer :spell_slots_3, default: 0
      t.integer :spell_slots_4, default: 0
      t.integer :spell_slots_5, default: 0
      t.integer :spell_slots_6, default: 0
      t.integer :spell_slots_7, default: 0
      t.integer :spell_slots_8, default: 0
      t.integer :spell_slots_9, default: 0
    end
  end
end
