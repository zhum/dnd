# == Schema Information
#
# Table name: weaponings
#
#  id        :integer          not null, primary key
#  player_id :integer
#  weapon_id :integer
#  count     :integer
#  max_count :integer
#

class Weaponing < ActiveRecord::Base
  belongs_to :player
  belongs_to :item, class_name: 'Weapon'
end
