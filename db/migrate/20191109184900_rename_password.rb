class RenamePassword < ActiveRecord::Migration[6.0]
  def change
    change_table :users do |t|
      t.rename :password, :password_hash
    end
  end
end
