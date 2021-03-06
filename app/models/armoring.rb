# == Schema Information
#
# Table name: armorings
#
#  id          :integer          not null, primary key
#  player_id   :integer
#  armor_id    :integer
#  count       :integer
#  max_count   :integer
#  wear        :boolean
#  proficiency :boolean
#
class Armoring < ActiveRecord::Base
  belongs_to :player
  belongs_to :item, class_name: 'Armor'

  before_create :update_proficiency

  def update_proficiency
    self.proficiency = false
    if ['dwarf_hill','dwarf_mountain','dwarf_gray'].include? self.player.race.name && !self.item.is_heavy
      self.proficiency = true
    end
    case self.player.klass.name
    when 'barbarian'
      self.proficiency = true if !self.item.is_heavy
    when 'fighter'
      self.proficiency = true
    when 'rouge'
      self.proficiency = true if self.item.is_light
    when 'monk'
      # ???
    when 'cleric'
      self.proficiency = true if !self.item.is_heavy || self.item.power==-1
    when 'palladin'
      self.proficiency = true
    when 'bard'
      self.proficiency = true if self.item.is_light
    when 'druid'
      # TODO: только не металлические!
      self.proficiency = true if !self.item.is_heavy || self.item.power==-1
    when 'wizard'
      # nope
    when 'warlock'
      self.proficiency = true if self.item.is_light
    when 'sorcerer'
      # nope
    when 'ranger'
      self.proficiency = true if !self.item.is_heavy || self.item.power==-1
    end
  end
end
