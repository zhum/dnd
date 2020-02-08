class AddCurrentStepToFight < ActiveRecord::Migration[6.0]
  def change
    change_table :fights do |t|
      t.integer   :current_step, default: 0
      t.boolean   :active,   default: false
      t.boolean   :ready,    default: false
      t.boolean   :finished, default: false
    end
  end
end
