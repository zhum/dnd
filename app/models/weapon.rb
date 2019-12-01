# string :name                                                                                                                                          
# integer :count                                                                                                                                        
# boolean :countable                                                                                                                                    
# string  :description                                                                                                                                  
# integer :dice                                                                                                                                         
# integer :of_dice

class Weapon < ActiveRecord::Base
  belongs_to :player
end