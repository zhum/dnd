class AddProficiencyToArmors < ActiveRecord::Migration[6.0]
  def change
  	change_table :armorings do |t|
  		t.boolean :proficiency
  	end
  end
end
