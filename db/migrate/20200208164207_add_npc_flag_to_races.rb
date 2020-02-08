class AddNpcFlagToRaces < ActiveRecord::Migration[6.0]
  def change
    change_table :races do |t|
      t.boolean :is_npc, default: true
    end
  end
end
