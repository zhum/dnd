class Player < ActiveRecord::Base
  validates_presence_of :name

  has_many :resources
  has_many :chars
  has_many :equipments
  has_many :weapons
  belongs_to :user
  belongs_to :adventure

  MODS = [
    'strength','dexterity','constitution',
    'intellegence','wisdom','charisma'
  ]

  def to_json
    h = ['id', 'name', 'klass', 'race', 'hp', 'max_hp', 'experience'].map{|name|
      [name, self.public_send(name)]
    }
    h << ['coins',[mcoins,scoins,gcoins,ecoins,pcoins]]
    h << ['chars',Hash[chars.map{|c| [c.name,c.value]}]]
    h << ['mods',Hash[MODS.map{|c| [c,public_send("mod_#{c}")]}]]
    h << ['equipments',Hash[equipments.all.map{|w| [w.id,w]}]]
    h << ['weapons',Hash[weapons.all.map{|w| [w.id,w]}]]
    warn "===> #{Hash[h].inspect}"
    Hash[h].to_json.to_s
    
  end
end