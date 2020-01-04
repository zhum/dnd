class CreateRaces < ActiveRecord::Migration[6.0]
  def change
  	create_table :races do |t|
  		t.string :name
  		t.string :description
  	end

  	remove_column :players, :race
  	add_reference :players, :race, foreign_key: true
  end
end
