class AddUserToPlayer < ActiveRecord::Migration[6.0]
  def change
    change_table :players do |t|
      t.belongs_to  :user
    end
  end
end
