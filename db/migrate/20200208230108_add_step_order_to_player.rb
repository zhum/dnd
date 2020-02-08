class AddStepOrderToPlayer < ActiveRecord::Migration[6.0]
  def change
    change_table :players do |t|
      t.integer :step_order, default: 0
    end
  end
end
