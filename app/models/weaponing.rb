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
# integer count
# integer max_count

class Weaponing < ActiveRecord::Base
  belongs_to :player
  belongs_to :weapon
end
