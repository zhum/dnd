class CreateSpells < ActiveRecord::Migration[6.0]
  def change
    create_table :spells do |t|
      t.string  :name
      t.string  :lasting_time
      t.string  :spell_time
      t.integer :level
      t.integer :slot
      t.string  :description
      t.string  :components
      t.integer :distance
    end

    create_table :spellings do |t|
      t.belongs_to :spell, foreign_key: true
      t.belongs_to :player, foreign_key: true
      t.boolean    :ready
    end

    create_table :spell_affects do |t|
      t.belongs_to :spelling, foreign_key: true
      t.belongs_to :player, foreign_key: true
      t.integer    :owner_id
    end
  end
end
