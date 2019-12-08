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

ActiveRecord::Schema.define(version: 2019_12_08_095524) do

  create_table "adventures", force: :cascade do |t|
    t.string "name"
  end

  create_table "armorings", force: :cascade do |t|
    t.integer "player_id"
    t.integer "armor_id"
    t.integer "count"
    t.integer "max_count"
    t.index ["armor_id"], name: "index_armorings_on_armor_id"
    t.index ["player_id"], name: "index_armorings_on_player_id"
  end

  create_table "armors", force: :cascade do |t|
    t.string "name"
    t.boolean "bad_stealth"
    t.integer "weight"
    t.integer "cost"
    t.integer "klass"
    t.boolean "add_sleight"
    t.string "description"
    t.integer "power"
    t.integer "max_add_sleight"
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

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.string "klass"
    t.string "race"
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
    t.boolean "is_master"
    t.integer "mod_strength"
    t.integer "mod_dexterity"
    t.integer "mod_constitution"
    t.integer "mod_intellegence"
    t.integer "mod_wisdom"
    t.integer "mod_charisma"
    t.integer "experience"
    t.index ["adventure_id"], name: "index_players_on_adventure_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "resources", force: :cascade do |t|
    t.integer "player_id"
    t.string "name"
    t.string "value"
    t.index ["player_id"], name: "index_resources_on_player_id"
  end

  create_table "things", force: :cascade do |t|
    t.string "name"
    t.integer "cost"
    t.integer "weight"
  end

  create_table "thingsing", force: :cascade do |t|
    t.integer "player_id"
    t.integer "thing_id"
    t.integer "count"
    t.string "modificator"
    t.index ["player_id"], name: "index_thingsing_on_player_id"
    t.index ["thing_id"], name: "index_thingsing_on_thing_id"
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
  end

end
