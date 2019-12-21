class Player < ActiveRecord::Base
  validates_presence_of :name

  has_many :resources
  has_many :chars
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

  after_initialize :set_def, unless: :persisted?

  def set_def
    self.hp ||= 20
    self.max_hp ||= 20
    self.mcoins ||= 0
    self.scoins ||= 0
    self.gcoins ||= 0
    self.ecoins ||= 0
    self.pcoins ||= 0
    self.is_master = false if self.is_master.nil?
    self.mod_strength ||= 0
    self.mod_dexterity ||= 0
    self.mod_constitution ||= 0
    self.mod_intellegence ||= 0
    self.mod_wisdom ||= 0
    self.mod_charisma ||= 0
    self.experience ||= 0
    MODS.map{ |c|
      if read_attribute("mod_#{c}").nil?
        write_attribute("mod_#{c}",1)
      end
    }
  end

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
    #I18n.default_locale = :ru
    h = ['id', 'name', 'klass', 'race', 'hp', 'max_hp', 'experience'].map{|name|
      [name, read_attribute(name)]
    }
    h << ['coins',[mcoins,scoins,gcoins,ecoins,pcoins]]
    h << ['chars',Hash[chars.map{|c| [c.name,c.value]}]]
    h << ['mods',Hash[MODS.map{|c| [c,read_attribute("mod_#{c}")]}]]

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

    h << ['skills',Hash[skillings.all.map { |e|
        s = e.skill; [e.id,{name: s.name,ready: e.ready, base: s.base, mod: e.modifier}]
      }
    ]]
    warn "===> #{Hash[h].inspect}"
    Hash[h].to_json.to_s 
  end
end