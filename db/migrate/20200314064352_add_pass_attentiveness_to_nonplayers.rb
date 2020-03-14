class AddPassAttentivenessToNonplayers < ActiveRecord::Migration[6.0]
  def change
    change_table :non_players do |t|
      t.integer :pass_attentiveness, default: 0
    end
  end
end
