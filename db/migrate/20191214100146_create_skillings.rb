class CreateSkillings < ActiveRecord::Migration[6.0]
  def change
    create_table :skillings do |t|
      t.belongs_to :player
      t.belongs_to :skill

      t.boolean    :ready
      t.integer    :modifier
    end
  end
end
