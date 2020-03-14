class AddIsDeadToNonplayers < ActiveRecord::Migration[6.0]
  def change
    change_table :non_players do |t|
      t.boolean :is_dead, default: false
    end
  end
end
