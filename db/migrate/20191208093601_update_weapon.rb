class UpdateWeapon < ActiveRecord::Migration[6.0]
  def change
  	create_table :weaponings do |t|
  		t.belongs_to :player
  		t.belongs_to :weapon

  		t.integer :count
  		t.integer :max_count
  	end

  	change_table :weapons do |t|
  		t.rename :dice, :damage
  		t.rename :of_dice, :damage_dice

  		t.remove :player_id
  		t.remove :count

  		t.integer :cost
  		t.integer :damage_type
  		t.integer :weight
  	end

    # +t.string "name"
    # -t.integer "count"
    # t.boolean "countable"
    # +t.string "description"
    # +t.integer "dice"
    # +t.integer "of_dice"
    # -t.integer "player_id"


    # +"name": "Боевой посох",
    # +"cost": 20,
    # +"damage": "1",
    # +"damage_dice": "6",
    # "damage_type": "дробящий",
    # "weight": 4,
    # "description": "Универсальное (1d8)"
  end
end
