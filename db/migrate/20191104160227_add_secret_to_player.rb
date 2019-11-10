class AddSecretToPlayer < ActiveRecord::Migration[6.0]
  def change
    change_table :players do |t|
      t.integer :secret
    end
  end
end
