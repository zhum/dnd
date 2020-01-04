class CreateKlasses < ActiveRecord::Migration[6.0]
  def change
  	create_table :klasses do |t|
  		t.string :name
  		t.string :description
  	end

  	remove_column :players, :klass
  	add_reference :players, :klass, foreighn_key: true
  end
end
