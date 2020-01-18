class Service
  class << self
    DTYPES={'дробящий' => 1, "колющий" => 2, "рубящий" => 3, "none" => 0}

    def load_json
      Data
    end

    def import_armor force=false
      return if Armor.count>0 and !force
      json = load_json['armor']
      json.each do |e|
        a = Armor.create(
          name: e['name'].strip,
          cost: e['cost'],
          klass: e['klass'],
          power: e['power'],
          bad_stealth: e['bad_stealth'],
          max_dexterity: e['max_dexterity'],
          weight: e['weight']
        )
        a.save
      end
    end
    def import_weapon force=false
      return if Weapon.count>0 && !force
      json = load_json['weapon']
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
          is_twohand: e['is_twohand']==true,
          is_throwable: e['is_throwable']==true,
          is_light: e['is_light']==true,
          is_heavy: e['is_heavy']==true,
          is_fencing: e['is_fencing']==true,
          is_universal: e['is_universal']==true,
        )
        a.save
      }
    end
    def import_things force=false
      return if Thing.count>0 && !force
      json = load_json['things']
      json.each { |e|
        a = Thing.create(
          name: e['name'].strip,
          cost: e['cost'].to_i,
          weight: (e['weight'].to_f*10).to_i
        )
        a.save
      }
    end
    def create_features force=false
      return if Feature.count>0 && !force
      json = load_json['features']
      json.each { |e|
        a = Feature.create(
          name: e[:name],
          description: e[:description],
          max_count: e[:max_count].to_i
        )
        a.save
      }
    end
    def create_skills force=false
      return if Skill.count>0 && !force
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

    def create_adventure force=false
      if Adventure.count>0 && !force
        return Adventure.first
      end
      a = Adventure.create(name: 'Преключениэ!')
      a.save
      a
    end

    def create_races force=false
      return if Race.count>0 && !force
      [ 'dwarf_hill',
        'dwarf_mountain',
        'dwarf_gray',
        'elf_high',
        'elf_wood',
        'elf_dark',
        'halfling_lightfoot',
        'halfling_stout',
        'human',
        'human_alternative',
        'dragonborn',
        'gnome_forest',
        'gnome_rock',
        'half-elf',
        'half-ork',
        'tiefling'
      ].each do |name|
        r = Race.create(name: name, description: '')
        r.save
      end
    end

    def create_klasses force=false
      return if Klass.count>0 && !force
      [
        'barbarian',
        'fighter',
        'rouge',
        'monk',
        'cleric',
        'palladin',
        'bard',
        'druid',
        'wizard',
        'warlock',
        'sorcerer',
        'ranger',
      ].each do |name|
        r = Klass.create(name: name, description: '')
        r.save
      end
    end

  end
  Data={
    "armor" => [
      {
        "name" => " Стеганый",
        "cost" => 500,
        "klass" => 1,
        "power" => 0,
        "bad_stealth" => true,
        "max_dexterity" => 1_000_000,
        "weight" => 8
      },
      {
        "name" => " Кожаный",
        "cost" => 1000,
        "klass" => 1,
        "power" => 0,
        "bad_stealth" => false,
        "max_dexterity" => 1_000_000,
        "weight" => 10
      },
      {
        "name" => " Проклепанная кожа",
        "cost" => 4500,
        "klass" => 2,
        "power" => 0,
        "bad_stealth" => false,
        "max_dexterity" => 1_000_000,
        "weight" => 13
      },
      {
        "name" => " Шкурный",
        "cost" => 1000,
        "klass" => 2,
        "power" => 0,
        "bad_stealth" => false,
        "max_dexterity" => 2,
        "weight" => 12
      },
      {
        "name" => " Кольчужная рубаха",
        "cost" => 5000,
        "klass" => 3,
        "power" => 0,
        "bad_stealth" => false,
        "max_dexterity" => 2,
        "weight" => 20
      },
      {
        "name" => " Чешуйчатый",
        "cost" => 5000,
        "klass" => 4,
        "power" => 0,
        "bad_stealth" => true,
        "max_dexterity" => 2,
        "weight" => 45
      },
      {
        "name" => " Кираса",
        "cost" => 40000,
        "klass" => 4,
        "power" => 0,
        "bad_stealth" => false,
        "max_dexterity" => 2,
        "weight" => 20
      },
      {
        "name" => " Полулаты",
        "cost" => 75000,
        "klass" => 5,
        "power" => 0,
        "bad_stealth" => true,
        "max_dexterity" => 2,
        "weight" => 40
      },
      {
        "name" => " Колечный",
        "cost" => 3000,
        "klass" => 4,
        "power" => 0,
        "bad_stealth" => true,
        "max_dexterity" => 0,
        "weight" => 40
      },
      {
        "name" => " Кольчуга",
        "cost" => 7500,
        "klass" => 6,
        "power" => 13,
        "bad_stealth" => true,
        "max_dexterity" => 0,
        "weight" => 55
      },
      {
        "name" => " Наборный",
        "cost" => 20000,
        "klass" => 7,
        "power" => 15,
        "bad_stealth" => true,
        "max_dexterity" => 0,
        "weight" => 60
      },
      {
        "name" => " Латы",
        "cost" => 150000,
        "klass" => 8,
        "power" => 15,
        "bad_stealth" => true,
        "max_dexterity" => 0,
        "weight" => 65
      },
      {
        "name" => " Щит",
        "cost" => 1000,
        "klass" => 2,
        "power" => -1,
        "bad_stealth" => false,
        "max_dexterity" => 1_000_000,
        "weight" => 6
      }
    ],
    "weapon" => [
      {
        "name" => "Боевой посох",
        "cost" => 20,
        "damage" => "1",
        "damage_dice" => "6",
        "damage_type" => "дробящий",
        "weight" => 4,
        "description" => "Универсальное (1d8)",
        "is_universal" => true
      },
      {
        "name" => "Булава",
        "cost" => 500,
        "damage" => "1",
        "damage_dice" => "6",
        "damage_type" => "дробящий",
        "weight" => 4,
        "description" => "-"
      },
      {
        "name" => " Дубинка",
        "cost" => 10,
        "damage" => "1",
        "damage_dice" => "4",
        "damage_type" => "дробящий",
        "weight" => 2,
        "description" => "Легкое ",
        "is_light" => true
      },
      {
        "name" => " Кинжал",
        "cost" => 200,
        "damage" => "1",
        "damage_dice" => "4",
        "damage_type" => "колющий",
        "weight" => 1,
        "description" => "Легкое, метательное (20/60),фехтовальное",
        "is_light" => true,
        "is_throwable" => true,
        "is_fencing" => true,
      },
      {
        "name" => " Копье",
        "cost" => 100,
        "damage" => "1",
        "damage_dice" => "6",
        "damage_type" => "колющий",
        "weight" => 3,
        "description" => "Метательное (20/60), Универсальное(1d8)",
        "is_throwable" => true,
        "is_universal" => true,
      },
      {
        "name" => " Легкий молот",
        "cost" => 200,
        "damage" => "1",
        "damage_dice" => "4",
        "damage_type" => "дробящий",
        "weight" => 2,
        "description" => "Легкое, метательное (20/60)",
        "is_light" => true,
        "is_throwable" => true,
      },
      {
        "name" => " Метательное копье",
        "cost" => 50,
        "damage" => "1",
        "damage_dice" => "6",
        "damage_type" => "колющий",
        "weight" => 2,
        "description" => "Метательное (дис. 30/120) ",
        "is_throwable" => true
      },
      {
        "name" => " Палица",
        "cost" => 20,
        "damage" => "1",
        "damage_dice" => "8",
        "damage_type" => "дробящий",
        "weight" => 10,
        "description" => "Двуручное",
        "is_twohand" => true,
      },
      {
        "name" => " Ручной топор",
        "cost" => 500,
        "damage" => "1",
        "damage_dice" => "6",
        "damage_type" => "рубящий",
        "weight" => 2,
        "description" => "Легкое, метательное",
        "is_light" => true,
        "is_throwable" => true,
      },
      {
        "name" => " Серп",
        "cost" => 100,
        "damage" => "1",
        "damage_dice" => "4",
        "damage_type" => "рубящий",
        "weight" => 2,
        "description" => "Легкое",
        "is_light" => true
      },
      {
        "name" => "Арбалет легкий",
        "cost" => 2500,
        "damage" => "1",
        "damage_dice" => "8",
        "weight" => 5,
        "damage_type" => "колющий",
        "description" => "Боеприпас (дис. 80/320), двуручное, перезарядка",
        "is_twohand" => true,
      },
      {
        "name" => "Дротик",
        "cost" => 5,
        "damage" => "1",
        "damage_dice" => "4",
        "damage_type" => "колющий",
        "weight" => 14,
        "description" => "Метательное (дис. 20/60), фехтовальное",
        "is_throwable" => true,
        "is_fencing" => true,
      },
      {
        "name" => " Короткий лук",
        "cost" => 2500,
        "damage" => "1",
        "damage_dice" => "6",
        "damage_type" => "колющий",
        "weight" => 2,
        "description" => "Боеприпас (дис. 80/320), двуручное",
        "is_twohand" => true,
      },
      {
        "name" => " Праща",
        "cost" => 10,
        "damage" => "1",
        "damage_dice" => "4",
        "damage_type" => "дробящий",
        "weight" => 0,
        "description" => "Боеприпас (дис. 30/120) "
      },
      {
        "name" => " Алебарда",
        "cost" => 2000,
        "damage" => "1",
        "damage_dice" => "10",
        "damage_type" => "рубящий",
        "weight" => 6,
        "description" => "Двуручное",
        "is_twohand" => true,
        "is_heavy" => true,
      },
      {
        "name" => " Боевая кирка",
        "cost" => 500,
        "damage" => "1",
        "damage_dice" => "8",
        "damage_type" => "колющий",
        "weight" => 2,
        "description" => "-"
      },
      {
        "name" => " Боевой молот",
        "cost" => 1500,
        "damage" => "1",
        "damage_dice" => "8",
        "damage_type" => "дробящий",
        "weight" => 2,
        "description" => "Универсальное (1d10)",
        "is_universal" => true,
      },
      {
        "name" => " Боевой топор",
        "cost" => 1000,
        "damage" => "1",
        "damage_dice" => "8",
        "damage_type" => "рубящий",
        "weight" => 4,
        "description" => "Универсальное (1d10) ",
        "is_universal" => true,
      },
      {
        "name" => " Глефа",
        "cost" => 2000,
        "damage" => "1",
        "damage_dice" => "10",
        "damage_type" => "рубящий",
        "weight" => 6,
        "description" => "Двуручное",
        "is_twohand" => true,
        "is_heavy" => true,
      },
      {
        "name" => " Двуручный меч",
        "cost" => 5000,
        "damage" => "2",
        "damage_dice" => "6",
        "damage_type" => "рубящий",
        "weight" => 6,
        "description" => "Двуручное",
        "is_twohand" => true,
        "is_heavy" => true,
      },
      {
        "name" => " Длинное копье",
        "cost" => 1000,
        "damage" => "1",
        "damage_dice" => "12",
        "damage_type" => "колющий",
        "weight" => 6,
        "description" => "Досягаемость, особое"
      },
      {
        "name" => " Длинный меч",
        "cost" => 1500,
        "damage" => "1",
        "damage_dice" => "8",
        "damage_type" => "рубящий",
        "weight" => 3,
        "description" => "Универсальное (1d10) ",
        "is_universal" => true,
      },
      {
        "name" => " Кнут",
        "cost" => 200,
        "damage" => "1",
        "damage_dice" => "4",
        "damage_type" => "рубящий",
        "weight" => 3,
        "description" => "Досягаемость,фехтовальное",
        "is_fencing" => true,
      },
      {
        "name" => " Короткий меч",
        "cost" => 1000,
        "damage" => "1",
        "damage_dice" => "6",
        "damage_type" => "колющий",
        "weight" => 2,
        "description" => "Легкое,фехтовальное",
        "is_light" => true,
        "is_fencing" => true,
      },
      {
        "name" => " Молот",
        "cost" => 1000,
        "damage" => "2",
        "damage_dice" => "6",
        "damage_type" => "дробящий",
        "weight" => 10,
        "description" => "Двуручное, тяжёлое",
        "is_twohand" => true,
        "is_heavy" => true,
      },
      {
        "name" => " Моргентштерн",
        "cost" => 1500,
        "damage" => "1",
        "damage_dice" => "8",
        "damage_type" => "колющий",
        "weight" => 4,
        "description" => "-"
      },
      {
        "name" => " Пика",
        "cost" => 500,
        "damage" => "1",
        "damage_dice" => "10",
        "damage_type" => "колющий",
        "weight" => 18,
        "description" => "Двуручное",
        "is_twohand" => true,
        "is_heavy" => true,
      },
      {
        "name" => " Рапира",
        "cost" => 2500,
        "damage" => "1",
        "damage_dice" => "8",
        "damage_type" => "колющий",
        "weight" => 2,
        "description" => "Фехтовальное",
        "is_fencing" => true,
      },
      {
        "name" => " Секира",
        "cost" => 3000,
        "damage" => "1",
        "damage_dice" => "12",
        "damage_type" => "рубящий",
        "weight" => 7,
        "description" => "Двуручное, тяжёлое",
        "is_twohand" => true,
        "is_heavy" => true,
      },
      {
        "name" => " Скимитар",
        "cost" => 2500,
        "damage" => "1",
        "damage_dice" => "6",
        "damage_type" => "рубящий",
        "weight" => 3,
        "description" => "Легкое",
        "is_light" => true,
        "is_fencing" => true,
      },
      {
        "name" => " Трезубец",
        "cost" => 500,
        "damage" => "1",
        "damage_dice" => "6",
        "damage_type" => "колющий",
        "weight" => 4,
        "description" => "Метательное (дис. 20/60), Универсальное(1d8)",
        "is_throwable" => true,
        "is_universal" => true,
      },
      {
        "name" => " Цеп",
        "cost" => 1000,
        "damage" => "1",
        "damage_dice" => "8",
        "damage_type" => "дробящий",
        "weight" => 2,
        "description" => "-"
      },
      {
        "name" => "Арбалет ручной",
        "cost" => 7500,
        "damage" => "1",
        "damage_dice" => "6",
        "weight" => 3,
        "damage_type" => "колющий",
        "description" => "Боеприпас (дис. 30/120), лёгкое, перезарядка",
        "is_light" => true,
      },
      {
        "name" => "Арбалет тяжелый",
        "cost" => 5000,
        "damage" => "1",
        "damage_dice" => "10",
        "weight" => 18,
        "damage_type" => "колющий",
        "description" => "Боеприпас (дис. 100/400), двуручное, перезарядка, тяжёлое",
        "is_twohand" => true,
        "is_heavy" => true,
      },
      {
        "name" => " Длинный лук",
        "cost" => 5000,
        "damage" => "1",
        "damage_dice" => "8",
        "damage_type" => "колющий",
        "weight" => 2,
        "description" => "Боеприпас (дис. 150/600), двуручное, тяжёлое",
        "is_heavy" => true,
        "is_twohand" => true,
      },
      {
        "name" => " Духовая трубка",
        "cost" => 1000,
        "damage" => "1",
        "damage_dice" => "0",
        "damage_type" => "колющий",
        "weight" => 1,
        "description" => "Боеприпас (дис. 25/100)"
      },
      {
        "name" => " Сеть",
        "cost" => 100,
        "damage" => "0",
        "damage_dice" => "0",
        "damage_type" => "none",
        "weight" => 3,
        "description" => "Метательное (дис. 5/15), особое",
        "is_throwable" => true
      }
    ],
    "things" => [
    {"name" => "Абак",
      "cost" => "200",
      "weight" => "2"
      },
      {"name" => "Мел (1 кусочек)",
      "cost" => "1",
      "weight" => "0"
      },
      {"name" => "Алхимический огонь (фляга)",
      "cost" => "5000",
      "weight" => "1"
      },
      {"name" => "Металлические шарики (1 000 шт. в сумке)",
      "cost" => "100",
      "weight" => "2"
      },
      {"name" => "Блок и лебёдка",
      "cost" => "100",
      "weight" => "5"
      },
      {"name" => "Мешок",
      "cost" => "1",
      "weight" => "0.5"
      },
      {"name" => "Мешочек с компонентами",
      "cost" => "2500",
      "weight" => "2"
      },
      {"name" => "Арбалетные болты (20)",
      "cost" => "100",
      "weight" => "1,5"
      },
      {"name" => "Молот, кузнечный",
      "cost" => "200",
      "weight" => "10"
      },
      {"name" => "Иглы для трубки (50)",
      "cost" => "100",
      "weight" => "1"
      },
      {"name" => "Молоток",
      "cost" => "100",
      "weight" => "3"
      },
      {"name" => "Снаряды для пращи (20)",
      "cost" => "4",
      "weight" => "1,5"
      },
      {"name" => "Мыло",
      "cost" => "2",
      "weight" => 0
      },
      {"name" => "Стрелы (20)",
      "cost" => "100",
      "weight" => "1"
      },
      {"name" => "Одежда, дорожная",
      "cost" => "200",
      "weight" => "4"
      },
      {"name" => "Бочка",
      "cost" => "200",
      "weight" => "70"
      },
      {"name" => "Одежда, костюм",
      "cost" => "500",
      "weight" => "4"
      },
      {"name" => "Бумага (один лист)",
      "cost" => "20",
      "weight" => 0
      },
      {"name" => "Одежда, обычная",
      "cost" => "50",
      "weight" => "3"
      },
      {"name" => "Бурдюк",
      "cost" => "20",
      "weight" => "5 (полн.)"
      },
      {"name" => "Одежда, отличная",
      "cost" => "1500",
      "weight" => "6"
      },
      {"name" => "Бутылка, стеклянная",
      "cost" => "200",
      "weight" => "2"
      },
      {"name" => "Одеяло",
      "cost" => "50",
      "weight" => "3"
      },
      {"name" => "Ведро",
      "cost" => "5",
      "weight" => "2"
      },
      {"name" => "Охотничий капкан",
      "cost" => "500",
      "weight" => "25"
      },
      {"name" => "Верёвка пеньковая (50 фт.)",
      "cost" => "100",
      "weight" => "10"
      },
      {"name" => "Палатка, двухместная",
      "cost" => "200",
      "weight" => "20"
      },
      {"name" => "Верёвка, шёлковая (50 фт.)",
      "cost" => "1000",
      "weight" => "5"
      },
      {"name" => "Пергамент (один лист)",
      "cost" => "10",
      "weight" => 0
      },
      {"name" => "Весы, торговые",
      "cost" => "500",
      "weight" => "3"
      },
      {"name" => "Песочные часы",
      "cost" => "2500",
      "weight" => "1"
      },
      {"name" => "Воск",
      "cost" => "50",
      "weight" => 0
      },
      {"name" => "Писчее перо",
      "cost" => "2",
      "weight" => 0
      },
      {"name" => "Горшок, железный",
      "cost" => "200",
      "weight" => "10"
      },
      {"name" => "Подзорная труба",
      "cost" => "1 00000",
      "weight" => "1"
      },
      {"name" => "Духи (флакон)",
      "cost" => "500",
      "weight" => 0
      },
      {"name" => "Противоядие (флакон)",
      "cost" => "5000",
      "weight" => 0
      },
      {"name" => "Замок",
      "cost" => "1000",
      "weight" => "1"
      },
      {"name" => "Рационы (1 день)",
      "cost" => "50",
      "weight" => "2"
      },
      {"name" => "Зелье лечения",
      "cost" => "5000",
      "weight" => "0.5"
      },
      {"name" => "Рюкзак",
      "cost" => "200",
      "weight" => "5"
      },
      {"name" => "Зеркало, стальное",
      "cost" => "500",
      "weight" => "0.5"
      },
      {"name" => "Ряса",
      "cost" => "100",
      "weight" => "4"
      },
      {"name" => "Калтропы (20 штук в сумке)",
      "cost" => "100",
      "weight" => "2"
      },
      {"name" => "Свеча",
      "cost" => "1",
      "weight" => 0
      },
      {"name" => "Кандалы",
      "cost" => "200",
      "weight" => "6"
      },
      {"name" => "Святая вода (фляга)",
      "cost" => "2500",
      "weight" => "1"
      },
      {"name" => "Кирка, горняцкая",
      "cost" => "200",
      "weight" => "10"
      },
      {"name" => "Кислота (флакон)",
      "cost" => "2500",
      "weight" => "1"
      },
      {"name" => "Амулет",
      "cost" => "500",
      "weight" => "1"
      },
      {"name" => "Книга",
      "cost" => "2500",
      "weight" => "5"
      },
      {"name" => "Реликварий",
      "cost" => "500",
      "weight" => "1"
      },
      {"name" => "Книга заклинаний",
      "cost" => "5000",
      "weight" => "3"
      },
      {"name" => "Эмблема",
      "cost" => "500",
      "weight" => 0
      },
      {"name" => "Колокольчик",
      "cost" => "100",
      "weight" => 0
      },
      {"name" => "Сигнальный свисток",
      "cost" => "5",
      "weight" => 0
      },
      {"name" => "Колчан",
      "cost" => "100",
      "weight" => "1"
      },
      {"name" => "Спальник",
      "cost" => "100",
      "weight" => "7"
      },
      {"name" => "Кольцо-печатка",
      "cost" => "500",
      "weight" => 0
      },
      {"name" => "Столовый набор",
      "cost" => "20",
      "weight" => "1"
      },
      {"name" => "Комплект для лазания",
      "cost" => "2500",
      "weight" => "12"
      },
      {"name" => "Сундук",
      "cost" => "500",
      "weight" => "25"
      },
      {"name" => "Комплект для рыбалки",
      "cost" => "100",
      "weight" => "4"
      },
      {"name" => "Таран, портативный",
      "cost" => "400",
      "weight" => "35"
      },
      {"name" => "Комплект целителя",
      "cost" => "500",
      "weight" => "3"
      },
      {"name" => "Точильный камень",
      "cost" => "1",
      "weight" => "1"
      },
      {"name" => "Контейнер для арбалетных болтов",
      "cost" => "100",
      "weight" => "1"
      },
      {"name" => "Трутница",
      "cost" => "50",
      "weight" => "1"
      },
      {"name" => "Контейнер для карт и свитков",
      "cost" => "100",
      "weight" => "1"
      },
      {"name" => "Увеличительное стекло",
      "cost" => "10000",
      "weight" => 0
      },
      {"name" => "Корзина",
      "cost" => "40",
      "weight" => "2"
      },
      {"name" => "Факел",
      "cost" => "1",
      "weight" => "1"
      },
      {"name" => "Кошель",
      "cost" => "50",
      "weight" => "1"
      },
      {"name" => "Флакон",
      "cost" => "100",
      "weight" => 0
      },
      {"name" => "Крюк-кошка",
      "cost" => "300",
      "weight" => "4"
      },
      {"name" => "Фляга или большая кружка",
      "cost" => "2",
      "weight" => "1"
      },
      {"name" => "Кувшин или графин",
      "cost" => "2",
      "weight" => "4"
      },
      {"name" => "Лампа",
      "cost" => "50",
      "weight" => "1"
      },
      {"name" => "Веточка омелы",
      "cost" => "100",
      "weight" => 0
      },
      {"name" => "Лестница (10 фт.)",
      "cost" => "10",
      "weight" => "25"
      },
      {"name" => "Деревянный посох",
      "cost" => "500",
      "weight" => "4"
      },
      {"name" => "Ломик",
      "cost" => "200",
      "weight" => "5"
      },
      {"name" => "Тисовая палочка",
      "cost" => "1000",
      "weight" => "1"
      },
      {"name" => "Лопата",
      "cost" => "200",
      "weight" => "5"
      },
      {"name" => "Тотем",
      "cost" => "100",
      "weight" => 0
      },
      {"name" => "Фонарь, закрытый",
      "cost" => "500",
      "weight" => "2"
      },
      {"name" => "Волшебная палочка",
      "cost" => "1000",
      "weight" => "1"
      },
      {"name" => "Фонарь, направленный",
      "cost" => "1000",
      "weight" => "2"
      },
      {"name" => "Жезл",
      "cost" => "1000",
      "weight" => "2"
      },
      {"name" => "Цепь (10 фт.)",
      "cost" => "500",
      "weight" => "10"
      },
      {"name" => "Кристалл",
      "cost" => "1000",
      "weight" => "1"
      },
      {"name" => "Чернила (бутылочка 30 грамм)",
      "cost" => "1000",
      "weight" => 0
      },
      {"name" => "Посох",
      "cost" => "500",
      "weight" => "4"
      },
      {"name" => "Шест (10 фт.)",
      "cost" => "5",
      "weight" => "7"
      },
      {"name" => "Сфера",
      "cost" => "2000",
      "weight" => "3"
      },
      {"name" => "Шипы, железные (10)",
      "cost" => "100",
      "weight" => "5"
      },
      {"name" => "Масло (фляга)",
      "cost" => "10",
      "weight" => "1"
      },
      {"name" => "Шлямбур",
      "cost" => "5",
      "weight" => "0.5"
      },
      {"name" => "Яд, простой (флакон)",
      "cost" => "10000",
      "weight" => 0
      }
    ],
    "features" => [
      {
        name: "Ярость",
        description: "",
        max_count: 1
      },
      {
        name: "Защита без доспехов",
        description: "Если вы не носите доспехов, ваш Класс Доспеха равен 10 + модификатор Ловкости + модификатор Телосложения. Вы можете использовать щит, не
теряя этого преимущества.",
        max_count: 0
      },
      {
        name: "Безрассудная атака",
        description: "",
        max_count: 0
      },
      {
        name: "Чувство опасности",
        description: "",
        max_count: 0
      },
      {
        name: "Путь дикости",
        description: "",
        max_count: 0
      },
      {
        name: "Быстрое передвижение",
        description: "",
        max_count: 0
      },
      {
        name: "Дополнительная атака",
        description: "",
        max_count: 0
      },
      {
        name: "Дикий инстинкт",
        description: "",
        max_count: 0
      },
      {
        name: "Сильный критический удар",
        description: "",
        max_count: 0
      },
      {
        name: "Непреклонная ярость",
        description: "",
        max_count: 0
      },
      {
        name: "Непрерывня ярость",
        description: "",
        max_count: 0
      },
      {
        name: "Неукротимая мощь",
        description: "",
        max_count: 0
      },
      {
        name: "Дикий чемпион",
        description: "",
        max_count: 0
      },
      {
        name: "Бешенство",
        description: "",
        max_count: 0
      },
      {
        name: "Бездумная ярость",
        description: "",
        max_count: 0
      },
      {
        name: "Пугающее присутствие",
        description: "",
        max_count: 0
      },
      {
        name: "Ответный удар",
        description: "",
        max_count: 0
      },#######################!!!!!!!!!!!!!!!!!!!!!#######################
      {
        name: "Мастер на все руки",
        description: "",
        max_count: 0
      },
      {
        name: "Божественный канал",
        description: "",
        max_count: 1
      },
      {
        name: "Второе дыхание",
        description: "",
        max_count: 1
      },
      {
        name: "Всплеск действий",
        description: "",
        max_count: 1
      },
    ]
  }
end
