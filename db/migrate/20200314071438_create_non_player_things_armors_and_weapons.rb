class CreateNonPlayerThingsArmorsAndWeapons < ActiveRecord::Migration[6.0]
  def change
    create_table :npc_things do |t|
      t.belongs_to :thing
      t.belongs_to :non_player

      t.integer :count
    end

    create_table :npc_weapons do |t|
      t.belongs_to :weapon
      t.belongs_to :non_player

      t.integer :count
    end

    create_table :npc_armors do |t|
      t.belongs_to :armor
      t.belongs_to :non_player

      t.integer :count
    end
  end
end
