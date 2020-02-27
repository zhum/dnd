# == Schema Information
#
# Table name: resources
#
#  id        :integer          not null, primary key
#  player_id :integer
#  name      :string
#  value     :string
#
class Resource < ActiveRecord::Base
  belongs_to :player
end
