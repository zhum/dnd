class Player < ActiveRecord::Base
  validates_presence_of :name

  has_many :resources
  has_many :chars
  has_many :equipments

  has_many :weaponings
  has_many :weapons, through: :weaponings

  has_many :armorings
  has_many :armors, through: :armorings

  has_many :thingings
  has_many :things, through: :thingings

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
    h << ['things',Hash[thingings.include(:thing).all.map{|t|
      tt=t.thing; [t.id,{name: tt.name, count: t.count, cost: tt.cost, weight: tt.weight}]}]
    ]
    h << ['armors',Hash[armorings.all.map{|a|
      aa = a.armoring; [a.id,{name: a.name, count: aa.count}]}]
    ]
    warn "===> #{Hash[h].inspect}"
    Hash[h].to_json.to_s
    
  end
end