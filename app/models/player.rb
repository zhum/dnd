# class Player
#   attr :hp, :id, :name, :klass, :race, :coins, :chars

#   def initialize
#     @id = 1001
#     @name = 'Харитон Прекрасный'
#     @klass = 'Повелитель'
#     @race = 'Горлум'
#     @hp = 123
#     @coins = [1,2,3,4,5]
#     @chars = {
#       'armour_class' => 18,
#       'initiative' => -1,
#       'speed' => 20,
#       'pass_attentiveness' => 20,
#       'masterlevel' => 2,
#       'hit_dice' => 3,
#       'hit_dice_of' => 10
#     }
#   end

#   def to_json
#     h = ['id', 'name', 'klass', 'race', 'hp', 'coins', 'chars'].map{|name|
#       [name, self.public_send(name)]
#     }
#     #warn "===> #{h.inspect}"
#     Hash[h].to_json.to_s
#   end
# end

class Player < ActiveRecord::Base
  validates_presence_of :name

  has_many :resources
  has_many :chars
  belongs_to :user
  belongs_to :adventure

  def to_json
    h = ['id', 'name', 'klass', 'race', 'hp'].map{|name|
      [name, self.public_send(name)]
    }
    h << ['coins',[mcoins,scoins,gcoins,ecoins,pcoins]]
    h << ['chars',Hash[chars.map{|c| [c.name,c.value]}]]
    #warn "===> #{h.inspect}"
    Hash[h].to_json.to_s
    
  end
end