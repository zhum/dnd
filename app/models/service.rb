class Service
  class << self
    def import_armor filename
      json = JSON.parse(File.read(filename))
      json.each { |e|
        a = Armor.create(
          name: e['name'].strip,
          cost: e['cost'],
          klass: e['klass'],
          power: e['power'],
          bad_stealth: e['bad_stealth'],
          add_sleight: e['add_sleight'],
          max_add_sleight: e['max_add_sleight'],
          weight: e['weight']
        )
        a.save
      }
    end
    def import_weapon filename
      json = JSON.parse(File.read(filename))
      json.each { |e|
        a = Weapon.create(
          name: e['name'].strip,
          cost: e['cost'],
          damage: e['damage'],
          damage_dice: e['damage_dice'],
          weight: e['weight'],
          description: e['description'],
        )
        a.save
      }
    end
  end
end
#    "name": "Боевой посох",
    "cost": 20,
    "damage": "1",
    "damage_dice": "6",
    "damage_type": "дробящий",
    "weight": 4,
    "description": "Универсальное (1d8)"
