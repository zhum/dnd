class CreatePlayersTable < ActiveRecord::Migration[6.0]
  def change
    create_table :players do |t|
      #t.serial :id
      t.string :name
      t.string :email
      t.string :klass
      t.string :race
      t.integer :hp
      t.integer :max_hp
      t.integer :mcoins
      t.integer :scoins
      t.integer :gcoins
      t.integer :ecoins
      t.integer :pcoins
    end
  end
end
