# == Schema Information
#
# Table name: races
#
#  id          :integer          not null, primary key
#  name        :string
#  description :string
#  is_npc      :boolean          default("1")
#
class Race < ActiveRecord::Base
  has_many :players
end
