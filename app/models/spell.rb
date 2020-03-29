# == Schema Information
#
# Table name: spells
#
#  id           :integer          not null, primary key
#  name         :string
#  lasting_time :string
#  spell_time   :string
#  level        :integer
#  slot         :integer
#  description  :string
#  components   :string
#  distance     :integer
#
class Spell < ActiveRecord::Base
  # t.string  :name
  # t.string  :lasting_time
  # t.string  :spell_time
  # t.integer :level
  # t.integer :slot
  # t.string  :description
  # t.string  :components
  # t.integer :distance
  has_many :spelling, inverse_of: :item
end
