class AddIsFighterToPlayer < ActiveRecord::Migration[6.0]
  def change
  	change_table :players do |t|
  		t.boolean  :is_fighter
  	end
  end
end
