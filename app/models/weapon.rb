# string :name                                                                                                                                          
# integer :count                                                                                                                                        
# boolean :countable                                                                                                                                    
# string  :description                                                                                                                                  
# integer :dice                                                                                                                                         
# integer :of_dice

class Weapon < ActiveRecord::Base
  #belongs_to :player
  has_many :weaponings

  def short_description
    "#{weight}фнт. #{damage}d#{damage_dice} #{damage_type} #{description}"
  end
end

    # "name": "Боевой посох",
    # "cost": 20,
    # "damage": "1",
    # "damage_dice": "6",
    # "damage_type": "дробящий",
    # "weight": 4,
    # "description": "Универсальное (1d8)"
