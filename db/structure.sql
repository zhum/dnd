CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE IF NOT EXISTS "chars" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "player_id" integer, "name" varchar, "value" varchar);
CREATE INDEX "index_chars_on_player_id" ON "chars" ("player_id");
CREATE TABLE IF NOT EXISTS "resources" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "player_id" integer, "name" varchar, "value" varchar);
CREATE INDEX "index_resources_on_player_id" ON "resources" ("player_id");
CREATE TABLE IF NOT EXISTS "adventures" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar);
CREATE TABLE IF NOT EXISTS "masters" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "adventure_id" integer, "user_id" integer);
CREATE INDEX "index_masters_on_adventure_id" ON "masters" ("adventure_id");
CREATE INDEX "index_masters_on_user_id" ON "masters" ("user_id");
CREATE TABLE IF NOT EXISTS "users" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "password_hash" varchar DEFAULT NULL, "email" varchar DEFAULT NULL, "active" boolean DEFAULT NULL, "secret" varchar DEFAULT NULL);
CREATE TABLE IF NOT EXISTS "messages" ("id" integer NOT NULL PRIMARY KEY, "text" varchar DEFAULT NULL, "player_id" integer DEFAULT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "to_master" boolean);
CREATE INDEX "index_messages_on_player_id" ON "messages" ("player_id");
CREATE TABLE IF NOT EXISTS "players" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "klass" varchar DEFAULT NULL, "race" varchar DEFAULT NULL, "hp" integer DEFAULT NULL, "max_hp" integer DEFAULT NULL, "mcoins" integer DEFAULT NULL, "scoins" integer DEFAULT NULL, "gcoins" integer DEFAULT NULL, "ecoins" integer DEFAULT NULL, "pcoins" integer DEFAULT NULL, "secret" integer DEFAULT NULL, "user_id" integer DEFAULT NULL, "adventure_id" integer DEFAULT NULL, "is_master" boolean DEFAULT NULL, "mod_strength" integer DEFAULT NULL, "mod_dexterity" integer DEFAULT NULL, "mod_constitution" integer DEFAULT NULL, "mod_intellegence" integer DEFAULT NULL, "mod_wisdom" integer DEFAULT NULL, "mod_charisma" integer DEFAULT NULL, "experience" integer);
CREATE INDEX "index_players_on_user_id" ON "players" ("user_id");
CREATE INDEX "index_players_on_adventure_id" ON "players" ("adventure_id");
CREATE TABLE IF NOT EXISTS "equipment" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "count" integer, "countable" boolean, "description" varchar, "player_id" integer);
CREATE INDEX "index_equipment_on_player_id" ON "equipment" ("player_id");
CREATE TABLE IF NOT EXISTS "armors" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "bad_stealth" boolean, "weight" integer, "cost" integer, "klass" integer, "add_sleight" boolean, "description" varchar, "power" integer, "max_add_sleight" integer);
CREATE TABLE IF NOT EXISTS "armorings" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "player_id" integer, "armor_id" integer, "count" integer, "max_count" integer);
CREATE INDEX "index_armorings_on_armor_id" ON "armorings" ("armor_id");
CREATE INDEX "index_armorings_on_player_id" ON "armorings" ("player_id");
CREATE TABLE IF NOT EXISTS "weaponings" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "player_id" integer, "weapon_id" integer, "count" integer, "max_count" integer);
CREATE INDEX "index_weaponings_on_player_id" ON "weaponings" ("player_id");
CREATE INDEX "index_weaponings_on_weapon_id" ON "weaponings" ("weapon_id");
CREATE TABLE IF NOT EXISTS "weapons" ("id" integer NOT NULL PRIMARY KEY, "name" varchar DEFAULT NULL, "countable" boolean DEFAULT NULL, "description" varchar DEFAULT NULL, "damage" integer DEFAULT NULL, "damage_dice" integer DEFAULT NULL, "cost" integer, "damage_type" integer, "weight" integer);
CREATE TABLE IF NOT EXISTS "things" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "cost" integer, "weight" integer);
CREATE TABLE IF NOT EXISTS "thingings" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "player_id" integer, "thing_id" integer, "count" integer, "modificator" varchar);
CREATE INDEX "index_thingings_on_thing_id" ON "thingings" ("thing_id");
CREATE INDEX "index_thingings_on_player_id" ON "thingings" ("player_id");
CREATE TABLE IF NOT EXISTS "prefs" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "player_id" integer, "name" varchar, "value" varchar);
CREATE INDEX "index_prefs_on_player_id" ON "prefs" ("player_id");
INSERT INTO "schema_migrations" (version) VALUES
('20191104083407'),
('20191104085415'),
('20191104160227'),
('20191105203900'),
('20191105203901'),
('20191105203902'),
('20191105203903'),
('20191107080500'),
('20191109184900'),
('20191116114100'),
('20191116114101'),
('20191116114102'),
('20191123203700'),
('20191123203701'),
('20191123203702'),
('20191124114900'),
('20191124114901'),
('20191126193602'),
('20191205203604'),
('20191205214646'),
('20191207181533'),
('20191207183650'),
('20191207185545'),
('20191208093601'),
('20191208095524'),
('20191208104157'),
('20191208100145');


