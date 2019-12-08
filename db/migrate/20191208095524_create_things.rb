class CreateThings < ActiveRecord::Migration[6.0]
  def change
  	create_table :things do |t|
  		t.string :name
  		t.integer :cost
  		t.integer :weight
  	end

  	create_table :thingsing do |t|
  		t.belongs_to :player
  		t.belongs_to :thing

  		t.integer :count
  		t.string  :modificator
  	end
  end
end
