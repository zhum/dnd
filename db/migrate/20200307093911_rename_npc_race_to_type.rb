class RenameNpcRaceToType < ActiveRecord::Migration[6.0]
  def change
  	change_table :non_players do |t|
  		t.rename :race_id, :npc_type_id
  	end
  end
end
