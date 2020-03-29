class AddTmpFlagToNpcType < ActiveRecord::Migration[6.0]
  def change
    change_table :npc_types do |t|
      t.boolean :is_tmp, default: false
    end
  end
end
