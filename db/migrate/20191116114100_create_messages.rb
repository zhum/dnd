class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.string :text
      t.belongs_to :player
      t.timestamps
    end
  end
end
