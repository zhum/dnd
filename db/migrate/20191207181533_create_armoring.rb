class CreateArmoring < ActiveRecord::Migration[6.0]
  def change
    create_table :armoring do |t|
      t.belongs_to :player
      t.belongs_to :armor
      t.integer    :count
      t.integer    :max_count
    end
  end
end
