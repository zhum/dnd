class AddRealInitiativeToPlayer < ActiveRecord::Migration[6.0]
  def change
    change_table :players do |t|
      t.integer :real_initiative
    end
  end
end
