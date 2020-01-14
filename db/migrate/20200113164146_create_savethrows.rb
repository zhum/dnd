class CreateSavethrows < ActiveRecord::Migration[6.0]
  def change
    create_table :save_throws do |t|
      t.integer :kind
      t.integer :count
      t.belongs_to :player
    end
  end
end
