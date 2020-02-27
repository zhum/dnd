# == Schema Information
#
# Table name: spell_affects
#
#  id          :integer          not null, primary key
#  spelling_id :integer
#  player_id   :integer
#  owner_id    :integer
#
class SpellAffect < ActiveRecord::Base
  belongs_to :spelling
  belongs_to :player
  belongs_to :owner, class_name: "Player", foreign_key: "owner_id"
end
