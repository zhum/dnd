class AddFaseToFight < ActiveRecord::Migration[6.0]
  def change
    change_table :fights do |t|
      t.integer  :fase, default: 0
      t.remove   :active
      t.remove   :ready
      t.remove   :finished
    end
  end
end
