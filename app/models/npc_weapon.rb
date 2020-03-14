# == Schema Information
#
# Table name: npc_weapons
#
#  id            :integer          not null, primary key
#  weapon_id     :integer
#  non_player_id :integer
#  count         :integer
#
class NpcWeapon < ActiveRecord::Base
  belongs_to :non_player
  belongs_to :weapon
end
