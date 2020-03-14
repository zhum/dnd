class AddFightGroup < ActiveRecord::Migration[6.0]
  def change
    create_table :fight_groups do |t|
      t.belongs_to :adventure
    end

    change_table :non_players do |t|
      t.belongs_to :fight_group
    end
  end
end
