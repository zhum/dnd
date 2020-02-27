# == Schema Information
#
# Table name: equipment
#
#  id          :integer          not null, primary key
#  name        :string
#  count       :integer
#  countable   :boolean
#  description :string
#  player_id   :integer
#
class Equipment < ActiveRecord::Base
  belongs_to :player
end
