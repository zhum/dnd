# == Schema Information
#
# Table name: spellings
#
#  id        :integer          not null, primary key
#  spell_id  :integer
#  player_id :integer
#  ready     :boolean
#
class Spelling < ActiveRecord::Base
  belongs_to :player
  belongs_to :item, class_name: 'Spell'
end
