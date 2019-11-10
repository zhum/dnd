class CreateUsersTable < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string  :name
      t.string  :password
      t.string  :email
      t.boolean :active
    end
  end
end
