class Player < ActiveRecord::Base
  validates_presence_of :name

  has_many :resources
  has_many :chars
  #has_many :equipments
  has_many :prefs

  has_many :weaponings
  has_many :weapons, through: :weaponings

  has_many :armorings
  has_many :armors, through: :armorings

  has_many :thingings
  has_many :things, through: :thingings

  has_many :skillings
  has_many :skills, through: :skillings

  belongs_to :user
  belongs_to :adventure

  MODS = [
    'strength','dexterity','constitution',
    'intellegence','wisdom','charisma'
  ]
  DTYPES=['none', 'дробящий', 'колющий', 'рубящий']


  def all_weapon
    weaponings.all.map{|w|
      ww = w.weapon;
      atrs = ['name','countable','description','damage',
              'damage_dice','cost','damage_type','weight'].map{|x|
        [x,ww.read_attribute(x)]
      }.append(['count', w.count]).append(['max_count', w.max_count])
      [w.id, Hash[atrs]]
    }
  end

  def add_weapon(w,count,max_count)
    weaponings << Weaponing.create!(count: count, max_count: max_count, weapon: w)
    save
  end

  def del_weapon(w)
    weaponing = if w.is_a?(Numeric)
      Weaponing.where(player_id: id, weapon_id: w)
    else
      Weaponing.where(player_id: id, weapon_id: w.id)
    end
    weaponing.delete
  end

  def reduce_money ammount
    total = mcoins+10*scoins+100*gcoins+50*ecoins+1000*pcoins
    total -= ammount
    total = 0 if total<0
    gc = total / 100
    total %= 100
    sc = total / 10
    mc = total % 10
    update(mcoins: mc, scoins: sc, gcoins: gc, ecoins: 0, pcoins: 0)
  end

  def to_json
    h = ['id', 'name', 'klass', 'race', 'hp', 'max_hp', 'experience'].map{|name|
      [name, read_attribute(name)]
    }
    h << ['coins',[mcoins,scoins,gcoins,ecoins,pcoins]]
    h << ['chars',Hash[chars.map{|c| [c.name,c.value]}]]
    h << ['mods',Hash[MODS.map{|c| [c,read_attribute("mod_#{c}")]}]]
    #h << ['equipments',Hash[equipments.all.map{|w| [w.id,'x' ]}]]

    h << ['weapons',Hash[all_weapon]]
    h << ['things',Hash[thingings.all.map{|t|
      tt=t.thing;
      [t.id,{count: t.count}.merge(Hash[
        ['name','cost','weight'].map{|x| [x,tt.read_attribute(x)]}])
      ]
    }]]
    h << ['armors',Hash[armorings.all.map{|a|
      aa = a.armor; [a.id, {name: aa.name, count: a.count}]}]
    ]
    warn "===> #{Hash[h].inspect}"
    Hash[h].to_json.to_s 
  end
end