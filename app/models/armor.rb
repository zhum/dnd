# == Schema Information
#
# Table name: armors
#
#  id              :integer          not null, primary key
#  name            :string
#  bad_stealth     :boolean
#  weight          :integer
#  cost            :integer
#  klass           :integer
#  description     :string
#  power           :integer
#  max_add_sleight :integer
#  max_dexterity   :integer
#  is_light        :boolean          default("0")
#  is_heavy        :boolean          default("0")
#
class Armor < ActiveRecord::Base
  has_many :armoring

  def short_description
    "#{weight}фнт. #{klass}кл. #{description}"
  end

  before_save :set_defaults

  def set_defaults
    self.is_universal = false if self.is_universal.nil?
    self.is_light = false if self.is_light.nil?
    self.is_heavy = false if self.is_heavy.nil?
    self.is_twohand = false if self.is_twohand.nil?
    self.is_throwable = false if self.is_throwable.nil?
    self.is_fencing = false if self.is_fencing.nil?
  end
end
