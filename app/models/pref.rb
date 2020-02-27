# == Schema Information
#
# Table name: prefs
#
#  id        :integer          not null, primary key
#  player_id :integer
#  name      :string
#  value     :string
#
class Pref < ActiveRecord::Base
  belongs_to :player
end
