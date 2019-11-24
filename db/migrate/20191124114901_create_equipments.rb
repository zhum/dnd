class CreateEquipments < ActiveRecord::Migration[6.0]
  def change
    create_table :equipment do |t|
      t.string :name
      t.integer :count
      t.boolean :countable
      t.string  :description
      t.belongs_to :player
    end
  end
end
