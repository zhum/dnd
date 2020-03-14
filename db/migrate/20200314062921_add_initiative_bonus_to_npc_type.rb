class AddInitiativeBonusToNpcType < ActiveRecord::Migration[6.0]
  def change
    change_table :npc_types do |t|
      t.integer :initiative, default: 0
      t.integer :pass_attentiveness, default: 0
    end
  end
end
