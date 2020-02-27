# == Schema Information
#
# Table name: chars
#
#  id        :integer          not null, primary key
#  player_id :integer
#  name      :string
#  value     :string
#
class Char < ActiveRecord::Base
  belongs_to :player
end
