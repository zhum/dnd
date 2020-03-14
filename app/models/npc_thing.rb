# == Schema Information
#
# Table name: npc_things
#
#  id            :integer          not null, primary key
#  thing_id      :integer
#  non_player_id :integer
#  count         :integer
#
class NpcThing < ActiveRecord::Base
  belongs_to :non_player
  belongs_to :thing
end
