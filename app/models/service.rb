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
  end
end