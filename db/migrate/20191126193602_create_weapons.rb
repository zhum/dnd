class CreateWeapons < ActiveRecord::Migration[6.0]
  def change
    create_table :weapons do |t|
      t.string :name
      t.integer :count
      t.boolean :countable
      t.string  :description
      t.integer :dice
      t.integer :of_dice
      t.belongs_to :player
    end
  end
end
