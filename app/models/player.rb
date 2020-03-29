# == Schema Information
#
# Table name: players
#
#  id                    :integer          not null, primary key
#  name                  :string
#  hp                    :integer
#  max_hp                :integer
#  mcoins                :integer
#  scoins                :integer
#  gcoins                :integer
#  ecoins                :integer
#  pcoins                :integer
#  secret                :integer
#  user_id               :integer
#  adventure_id          :integer
#  is_master             :boolean          default("1")
#  mod_strength          :integer
#  mod_dexterity         :integer
#  mod_constitution      :integer
#  mod_intellegence      :integer
#  mod_wisdom            :integer
#  mod_charisma          :integer
#  experience            :integer
#  race_id               :integer
#  klass_id              :integer
#  mod_prof_dexterity    :boolean
#  mod_prof_wisdom       :boolean
#  mod_prof_constitution :boolean
#  mod_prof_strength     :boolean
#  mod_prof_intellegence :boolean
#  mod_prof_charisma     :boolean
#  spell_slots_1         :integer          default("0")
#  spell_slots_2         :integer          default("0")
#  spell_slots_3         :integer          default("0")
#  spell_slots_4         :integer          default("0")
#  spell_slots_5         :integer          default("0")
#  spell_slots_6         :integer          default("0")
#  spell_slots_7         :integer          default("0")
#  spell_slots_8         :integer          default("0")
#  spell_slots_9         :integer          default("0")
#  step_order            :integer          default("0")
#  is_fighter            :boolean
#  real_initiative       :integer
#

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

  has_many :featurings
  has_many :features, through: :featurings

  has_many :spellings
  has_many :spells, through: :spellings
  has_many :spell_affects
  has_many :spell_actives, class_name: "SpellAffect", foreign_key: "owner_id"

  has_many :save_throws

  belongs_to :user
  belongs_to :adventure
  belongs_to :race
  belongs_to :klass

  MODS = [
    'strength','dexterity','constitution',
    'intellegence','wisdom','charisma'
  ]
  CHARS = ['armor_class', 'initiative', 'speed',
           'pass_attentiveness', 'masterlevel','hit_dice','hit_dice_of']

  DTYPES = ['none', 'дробящий', 'колющий', 'рубящий']

  AC_FORMULAS = {
    "Обычная защита" => 
      lambda { |x,wear|
        dex = x.mod_dexterity
        #logger.warn x.inspect+'//'+wear.inspect
        base = 10+(wear.map{|e| e.klass}.reduce(:+) || 0) +
               (wear.map{|w| w.max_dexterity} << dex).min

        base + case x.klass.name
        when 'barbarian'
          # add constitution and shield af any
          wear.any?{|w| w.power != -1} ? 0 : x.mod_constitution
        when 'monk'
          wear.size>0 ? 0 : mod_wisdom
        else
          0
        end
      }
  }
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
    MODS.each{ |c|
      if read_attribute("mod_#{c}").nil?
        write_attribute("mod_#{c}",1)
      end
    }
    CHARS.each { |c|
      unless self.chars.find_by name: c
        self.chars << Char.create(name: c, value: 1)
      end
    }
    ['athletics',
     'acrobatics',
     'investigation',
     'perception',
     'survival',
     'performance',
     'intimidation',
     'history',
     'sleight_of_hands',
     'arcana',
     'medicine',
     'deception',
     'nature',
     'insight',
     'religion',
     'stealth',
     'persuasion',
     'animal_handling'
    ].each do |k|
      unless self.skillings.find_by name: k
        self.skillings << Skilling.create(
          skill: Skill.find_by(name: k),
          ready: false,
          modifier: 0
        )
      end
    end
  end

  def get_mod name_or_index
    attr_name = if name_or_index.is_a?(String) or name_or_index.is_a?(Symbol)
      "mod_#{name_or_index.to_s}"
    else
      "mod_#{MODS[name_or_index.to_i]}"
    end

    read_attribute(attr_name)
  end

  def get_default_armor_class armors
    if armors.size>0
      armors.map{|a|
        a.klass + [self.mod_dexterity, a.max_dexterity].min
      }.sum
    else
      10+self.mod_dexterity
    end    
  end

  def set_char name_or_index, value
    attr_name = if name_or_index.is_a?(String) or name_or_index.is_a?(Symbol)
      name_or_index.to_s
    else
      CHARS[name_or_index.to_i]
    end
    self.write_attribute(attr_name,value)    
  end

  def get_char name_or_index
    attr_name = if name_or_index.is_a?(String) or name_or_index.is_a?(Symbol)
      name_or_index.to_s
    else
      CHARS[name_or_index.to_i]
    end

    case attr_name
    when 'armor_class'
      w_armors = armorings.select {|a| a.wear}.map{|w| w.armor}
      #wear = (w_armors.size > 0) ? 0 : 1
      (
        features.select{|f|
          AC_FORMULAS.has_key? f.name
        }.map{|f|
          AC_FORMULAS[f.name].call(self,w_armors)
        } << AC_FORMULAS['Обычная защита'].call(self,w_armors)
      ).max
    when 'speed'
      base = chars.where(name: 'speed').take.value
      if armorings.all.any?{|x| x.wear && x.armor.is_heavy}
        if self.race.name != 'dwarf_mountain' && self.race.name != 'dwarf_hill' &&
           self.race.name != 'dwarf_gray'
          return base - 10 if x.armor.power < self.mod_strength
        end
      end
      base
    else
      #warn attr_name
      chars.where(name: attr_name).take.value
    end
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

  # returns true if money was reduced
  def reduce_money amount
    total = mcoins+10*scoins+100*gcoins+50*ecoins+1000*pcoins
    return false if total < amount
    total -= amount
    pc = total / 1000
    total %= 1000
    gc = total / 100
    total %= 100
    em = 0
    if total > 50
      total -= 50
      em = 1
    end
    sc = total / 10
    mc = total % 10
    update(mcoins: mc, scoins: sc, gcoins: gc, ecoins: em, pcoins: pc)
    true
  end

  def to_json
    I18n.default_locale = :ru
    h = ['id', 'name', 'hp', 'max_hp',
         'experience', 'weapon_proficiency'].map{|name|
      [name, read_attribute(name)]
    }
    #h << ['armor_class', get_char('armor_class')]
    h << ['race',I18n.t("char.#{self.race.name}")]
    h << ['klass', I18n.t("char.#{self.klass.name}")]
    h << ['coins',[mcoins,scoins,gcoins,ecoins,pcoins]]
    h << ['chars',Hash[chars.map{|c| [c.name,self.get_char(c.name)]}]] #c.value.to_i
    h << ['mods',Hash[MODS.map{|c| [c,[read_attribute("mod_#{c}"),read_attribute("mod_prof_#{c}") ? '1' : '0']]}]]

    h << ['weapons',Hash[all_weapon]]
    h << ['things',Hash[thingings.all.map{|t|
      tt=t.thing;
      [t.id,{count: t.count}.merge(Hash[
        ['name','cost','weight'].map{|x| [x,tt.read_attribute(x)]}])
      ]
    }]]
    h << ['armors',Hash[self.armorings.all.map{|a|
      #logger.warn "A=#{a.inspect}"
      aa = a.armor
      [a.id, {name: aa.name, count: a.count, wear: a.wear}]}]
    ]

    1.upto(9) { |n| h << ["spells_#{n}", self.read_attribute("spell_slots_#{n}")]}
    h << ['skills',Hash[self.skillings.all.map { |e|
        s = e.skill
        [e.id, {name: s.name,
                ready: e.ready,
                base: s.base,
                mod: e.value}]
      }
    ]]
    h << ['features',Hash[self.featurings.all.map { |e|
        s = e.feature
        [e.id, {name: s.name,
                max_count: s.max_count,
                description: s.description,
                count: e.count}]
      }
    ]]

    h << ['spells',Hash[self.spellings.all.map { |e|
        s = e.spell
        [s.id, {name: s.name,
                description: s.description,
                ready: e.ready ? true : false,
                level: s.level,
                spell_time: s.spell_time,
                lasting_time: s.lasting_time,
                components: s.components,
                distance: s.distance,
                active: (self.spell_actives.where(spelling: e).count > 0),
        }]
      }
    ]]

    s = get_save_throws 1
    h << [:savethrows1, s ? s.count : 0]
    s = get_save_throws 2
    h << [:savethrows2, s ? s.count : 0]

    h << [:bad_stealth, self.get_bad_stealth]
    h << [:total_weight, total_weight]
    #warn "===> #{Hash[h].inspect}"
    bads = [get_bads_from_wear].reject{|x| x.nil?}
    h << [:bads, bads]
    Hash[h].to_json.to_s 
  end

  def get_save_throws kind
    save_throws.where(kind: kind).take
  end

  def self.try_create user, params
    warn "params: #{params.inspect}"
    # skills = Skill.find_by_id(params[:skills])
    # features = Feature.find_by_id(params[:features])
    player = self.create(
      name: params[:reg_name],
      user: user,
      adventure: Adventure.find_by_id(params[:adventure]),
      race: params[:race],
      klass: params[:klass],
      mod_strength: params[:strength].to_i,
      mod_dexterity: params[:dexterity].to_i,
      mod_constitution: params[:constitution].to_i,
      mod_intellegence: params[:intellegence].to_i,
      mod_wisdom: params[:wisdom].to_i,
      mod_charisma: params[:charisma].to_i,

      hp: params[:hp].to_i,
      max_hp: params[:max_hp].to_i,
      experience: params[:experience].to_i,
      mcoins: 1,
      scoins: 1,
      gcoins: 1,
      ecoins: 1,
      pcoins: 1,
      is_master: false
    )
    player.skillings = Skill.all.map{|s|
      Skilling.create(skill: s, modifier: 1, ready: params[:skills].include?(s.id.to_s))
    }
    player.featurings = Feature.where(id: params[:features]).map {|f|
      Featuring.create(feature: f, count: 1)
    }
    player.save_throws << SaveThrow.create(kind: 1, count: 0)
    player.save_throws << SaveThrow.create(kind: 2, count: 0)
    player.save!
    player
  end

  def get_bad_stealth
    bad = Armoring.all.any?{ |a|
      #logger.warn "#{a.armor.bad_stealth} && #{a.wear}"
      a.armor.bad_stealth && a.wear
    }
  end

  def get_speed_low
    bad = Armoring.all.any?{ |a|
      a.armor.is_heavy && a.wear && a.armor.power>self.get_mod(:strength)
    }
    if bad
      10
    else
      0
    end
  end

  def get_bads_from_wear
    bad = armorings.any?{ |a|
      logger.warn "--- #{a.armor.name}/#{a.wear}/#{a.proficiency}"
      a.wear && ! a.proficiency
    }
    if bad
      "Помехи к Силе и Ловкости, нельзя использовать заклинания"
    else
      nil
    end
  end

  def total_weight
    w = armors.all.inject(0){ |mem, var| mem += var.weight } +
      things.all.inject(0.0){ |mem, var| mem += var.weight/10.0 } +
      weapons.inject(0){ |mem, var| mem += var.weight } +
      (mcoins+scoins+gcoins+pcoins+ecoins)/50.0
    "%0.2f" % w
  end

end
