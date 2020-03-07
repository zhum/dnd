class CreateNpcTypes < ActiveRecord::Migration[6.0]
  def change
  	create_table :npc_types do |t|
  		t.string :name
  		t.string :description
  		t.integer :max_hp
  		t.integer :armor_class
  	end
  end
end
