class Service
  class << self
    DTYPES={'дробящий' => 1, "колющий" => 2, "рубящий" => 3, "none" => 0}
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
          damage_type: DTYPES[e['damage_type']],
          weight: e['weight'],
          countable: false,
          description: e['description'].strip,
        )
        a.save
      }
    end
    def import_things filename
      json = JSON.parse(File.read(filename))
      json.each { |e|
        a = Thing.create(
          name: e['name'].strip,
          cost: e['cost'].to_i,
          weight: (e['weight'].to_f*10).to_i
        )
        a.save
      }
    end
  end
end
__END__