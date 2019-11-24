class CreateEquipment < ActiveRecord::Migration[6.0]
  def change
    create_table :equipments do |t|
      t.string :name
      t.integer :count
      t.belongs_to :player
    end
  end
end
