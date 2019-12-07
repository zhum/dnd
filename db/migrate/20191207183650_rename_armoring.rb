class RenameArmoring < ActiveRecord::Migration[6.0]
  def change
    rename_table :armoring, :armorings
  end
end
