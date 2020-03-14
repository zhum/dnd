# == Schema Information
#
# Table name: npc_armors
#
#  id            :integer          not null, primary key
#  armor_id      :integer
#  non_player_id :integer
#  count         :integer
#
class NpcArmor < ActiveRecord::Base
  belongs_to :non_player
  belongs_to :armor
end
