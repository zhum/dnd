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
    def create_skills
      {'athletics' => 1,
      'acrobatics' => 3,
      'investigation' => 0,
      'perception' => 4,
      'survival' => 4,
      'performance' => 5,
      'intimidation' => 5,
      'history' => 3,
      'sleight_of_hands' => 1,
      'arcana' => 3,
      'medicine' => 4,
      'deception' => 5,
      'nature' => 3,
      'insight' => 4,
      'religion' => 3,
      'stealth' => 1,
      'persuasion' => 5,
      'animal_handling' => 4}.each do |k,v|
        Skill.create(name: k, base: v).save
      end

    end
  end
end
__END__