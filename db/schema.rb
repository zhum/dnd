# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_02_09_150105) do

  create_table "adventures", force: :cascade do |t|
    t.string "name"
    t.boolean "opened"
  end

  create_table "armorings", force: :cascade do |t|
    t.integer "player_id"
    t.integer "armor_id"
    t.integer "count"
    t.integer "max_count"
    t.boolean "wear"
    t.boolean "proficiency"
    t.index ["armor_id"], name: "index_armorings_on_armor_id"
    t.index ["player_id"], name: "index_armorings_on_player_id"
  end

  create_table "armors", force: :cascade do |t|
    t.string "name"
    t.boolean "bad_stealth"
    t.integer "weight"
    t.integer "cost"
    t.integer "klass"
    t.string "description"
    t.integer "power"
    t.integer "max_add_sleight"
    t.integer "max_dexterity"
    t.boolean "is_light", default: false
    t.boolean "is_heavy", default: false
  end

  create_table "chars", force: :cascade do |t|
    t.integer "player_id"
    t.string "name"
    t.string "value"
    t.index ["player_id"], name: "index_chars_on_player_id"
  end

  create_table "equipment", force: :cascade do |t|
    t.string "name"
    t.integer "count"
    t.boolean "countable"
    t.string "description"
    t.integer "player_id"
    t.index ["player_id"], name: "index_equipment_on_player_id"
  end

  create_table "features", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "max_count"
  end

  create_table "featurings", force: :cascade do |t|
    t.integer "player_id"
    t.integer "feature_id"
    t.integer "count"
    t.index ["feature_id"], name: "index_featurings_on_feature_id"
    t.index ["player_id"], name: "index_featurings_on_player_id"
  end

  create_table "fights", force: :cascade do |t|
    t.integer "adventure_id"
    t.integer "current_step", default: 0
    t.boolean "active", default: false
    t.boolean "ready", default: false
    t.boolean "finished", default: false
    t.index ["adventure_id"], name: "index_fights_on_adventure_id"
  end

  create_table "klasses", force: :cascade do |t|
    t.string "name"
    t.string "description"
  end

  create_table "masters", force: :cascade do |t|
    t.string "name"
    t.integer "adventure_id"
    t.integer "user_id"
    t.index ["adventure_id"], name: "index_masters_on_adventure_id"
    t.index ["user_id"], name: "index_masters_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "text"
    t.integer "player_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "to_master"
    t.index ["player_id"], name: "index_messages_on_player_id"
  end

  create_table "non_players", force: :cascade do |t|
    t.integer "race_id"
    t.integer "fight_id"
    t.string "name"
    t.integer "max_hp"
    t.integer "hp"
    t.integer "armor_class"
    t.integer "initiative"
    t.integer "step_order"
    t.index ["fight_id"], name: "index_non_players_on_fight_id"
    t.index ["race_id"], name: "index_non_players_on_race_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.integer "hp"
    t.integer "max_hp"
    t.integer "mcoins"
    t.integer "scoins"
    t.integer "gcoins"
    t.integer "ecoins"
    t.integer "pcoins"
    t.integer "secret"
    t.integer "user_id"
    t.integer "adventure_id"
    t.boolean "is_master", default: true
    t.integer "mod_strength"
    t.integer "mod_dexterity"
    t.integer "mod_constitution"
    t.integer "mod_intellegence"
    t.integer "mod_wisdom"
    t.integer "mod_charisma"
    t.integer "experience"
    t.integer "race_id"
    t.integer "klass_id"
    t.boolean "mod_prof_dexterity"
    t.boolean "mod_prof_wisdom"
    t.boolean "mod_prof_constitution"
    t.boolean "mod_prof_strength"
    t.boolean "mod_prof_intellegence"
    t.boolean "mod_prof_charisma"
    t.integer "spell_slots_1", default: 0
    t.integer "spell_slots_2", default: 0
    t.integer "spell_slots_3", default: 0
    t.integer "spell_slots_4", default: 0
    t.integer "spell_slots_5", default: 0
    t.integer "spell_slots_6", default: 0
    t.integer "spell_slots_7", default: 0
    t.integer "spell_slots_8", default: 0
    t.integer "spell_slots_9", default: 0
    t.integer "step_order", default: 0
    t.boolean "is_fighter"
    t.integer "real_initiative"
    t.index ["adventure_id"], name: "index_players_on_adventure_id"
    t.index ["klass_id"], name: "index_players_on_klass_id"
    t.index ["race_id"], name: "index_players_on_race_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "prefs", force: :cascade do |t|
    t.integer "player_id"
    t.string "name"
    t.string "value"
    t.index ["player_id"], name: "index_prefs_on_player_id"
  end

  create_table "races", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "is_npc", default: true
  end

  create_table "resources", force: :cascade do |t|
    t.integer "player_id"
    t.string "name"
    t.string "value"
    t.index ["player_id"], name: "index_resources_on_player_id"
  end

  create_table "save_throws", force: :cascade do |t|
    t.integer "kind"
    t.integer "count"
    t.integer "player_id"
    t.index ["player_id"], name: "index_save_throws_on_player_id"
  end

  create_table "skillings", force: :cascade do |t|
    t.integer "player_id"
    t.integer "skill_id"
    t.boolean "ready"
    t.integer "modifier"
    t.index ["player_id"], name: "index_skillings_on_player_id"
    t.index ["skill_id"], name: "index_skillings_on_skill_id"
  end

  create_table "skills", force: :cascade do |t|
    t.string "name"
    t.integer "base"
  end

  create_table "spell_affects", force: :cascade do |t|
    t.integer "spelling_id"
    t.integer "player_id"
    t.integer "owner_id"
    t.index ["player_id"], name: "index_spell_affects_on_player_id"
    t.index ["spelling_id"], name: "index_spell_affects_on_spelling_id"
  end

  create_table "spellings", force: :cascade do |t|
    t.integer "spell_id"
    t.integer "player_id"
    t.boolean "ready"
    t.index ["player_id"], name: "index_spellings_on_player_id"
    t.index ["spell_id"], name: "index_spellings_on_spell_id"
  end

  create_table "spells", force: :cascade do |t|
    t.string "name"
    t.string "lasting_time"
    t.string "spell_time"
    t.integer "level"
    t.integer "slot"
    t.string "description"
    t.string "components"
    t.integer "distance"
  end

  create_table "thingings", force: :cascade do |t|
    t.integer "player_id"
    t.integer "thing_id"
    t.integer "count"
    t.string "modificator"
    t.index ["player_id"], name: "index_thingings_on_player_id"
    t.index ["thing_id"], name: "index_thingings_on_thing_id"
  end

  create_table "things", force: :cascade do |t|
    t.string "name"
    t.integer "cost"
    t.integer "weight"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "password_hash"
    t.string "email"
    t.boolean "active"
    t.string "secret"
  end

  create_table "weaponings", force: :cascade do |t|
    t.integer "player_id"
    t.integer "weapon_id"
    t.integer "count"
    t.integer "max_count"
    t.index ["player_id"], name: "index_weaponings_on_player_id"
    t.index ["weapon_id"], name: "index_weaponings_on_weapon_id"
  end

  create_table "weapons", force: :cascade do |t|
    t.string "name"
    t.boolean "countable"
    t.string "description"
    t.integer "damage"
    t.integer "damage_dice"
    t.integer "cost"
    t.integer "damage_type"
    t.integer "weight"
    t.boolean "is_fencing", default: false
    t.boolean "is_universal", default: false
    t.boolean "is_twohand", default: false
    t.boolean "is_throwable", default: false
  end

  add_foreign_key "players", "races"
  add_foreign_key "spell_affects", "players"
  add_foreign_key "spell_affects", "spellings"
  add_foreign_key "spellings", "players"
  add_foreign_key "spellings", "spells"
end
