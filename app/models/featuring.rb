# == Schema Information
#
# Table name: featurings
#
#  id         :integer          not null, primary key
#  player_id  :integer
#  feature_id :integer
#  count      :integer
#
class Featuring < ActiveRecord::Base
  belongs_to :item, class_name: 'Feature'
  belongs_to :player
end
