# == Schema Information
#
# Table name: non_players
#
#  id          :integer          not null, primary key
#  race_id     :integer
#  fight_id    :integer
#  name        :string
#  max_hp      :integer
#  hp          :integer
#  armor_class :integer
#  initiative  :integer
#  step_order  :integer
#
# string     :name
# integer    :max_hp
# integer    :hp
# integer    :armor_class
# integer    :initiative
# integer    :step_order

class NonPlayer < ActiveRecord::Base
  validates_presence_of :name
  belongs_to :race
  belongs_to :fight

  def self.generate race, fight
    npc = create!(
      race: race, fight: fight, name: 'none',
      max_hp: 100, hp: 100, armor_class: 20,
      initiative: 1, step_order: 1)
    npc.name = "NPC-#{npc.id}"
    npc.save
    npc
  end
end
