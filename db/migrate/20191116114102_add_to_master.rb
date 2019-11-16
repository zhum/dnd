class AddToMaster < ActiveRecord::Migration[6.0]
  def change
    change_table :messages do |t|
      t.boolean :to_master
    end
  end
end
