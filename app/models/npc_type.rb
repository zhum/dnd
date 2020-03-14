# == Schema Information
#
# Table name: npc_types
#
#  id          :integer          not null, primary key
#  name        :string
#  description :string
#  max_hp      :integer
#  armor_class :integer
#
class NpcType < ActiveRecord::Base
  has_many :npc
end
