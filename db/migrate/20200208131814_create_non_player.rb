class CreateNonPlayer < ActiveRecord::Migration[6.0]
  def change
    create_table :non_players do |t|
      t.belongs_to :race
      t.belongs_to :fight
      t.string     :name
      t.integer    :max_hp
      t.integer    :hp
      t.integer    :armor_class
      t.integer    :initiative
      t.integer    :step_order
    end
  end
end
