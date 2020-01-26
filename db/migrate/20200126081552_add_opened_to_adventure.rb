class AddOpenedToAdventure < ActiveRecord::Migration[6.0]
  def change
    change_table :adventures do |t|
      t.boolean :opened
    end
  end
end
