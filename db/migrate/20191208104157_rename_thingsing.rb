class RenameThingsing < ActiveRecord::Migration[6.0]
  def change
  	rename_table :thingsing, :thingings
  end
end
