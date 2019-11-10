class CreateCharsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :chars do |t|
      t.belongs_to :player
      t.string :name
      t.string :value
    end
    create_table :resources do |t|
      t.belongs_to :player
      t.string :name
      t.string :value
    end
  end
end
