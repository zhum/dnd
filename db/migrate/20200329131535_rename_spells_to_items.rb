class RenameSpellsToItems < ActiveRecord::Migration[6.0]
  def change
    change_table :spellings do |t|
      t.rename :spell_id, :item_id
    end
  end
end
