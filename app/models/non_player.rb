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
    name = "#{race.name} #{get_next_id(fight,race)}"
    logger.warn "name=#{name}"
    npc = create!(
      race: race, fight: fight, name: name,
      max_hp: 100, hp: 100, armor_class: 20,
      initiative: 1, step_order: 1)
    
    npc.save
    npc
  end

  def self.get_next_id fight, race
    count = fight.get_fighters(true).select { |e| e[:race_id] == race.id}.count
    count+1
  end
end
