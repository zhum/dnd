class AddExpToPlayer < ActiveRecord::Migration[6.0]
  def change
    change_table :players do |t|
      t.integer :experience
    end
  end
end
