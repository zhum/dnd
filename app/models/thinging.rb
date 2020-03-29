# == Schema Information
#
# Table name: thingings
#
#  id          :integer          not null, primary key
#  player_id   :integer
#  thing_id    :integer
#  count       :integer
#  modificator :string
#
class Thinging < ActiveRecord::Base
  belongs_to :item, class_name: 'Thing' 
  belongs_to :player

  #count
  #modificator
end
