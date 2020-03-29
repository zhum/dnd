# == Schema Information
#
# Table name: weapons
#
#  id           :integer          not null, primary key
#  name         :string
#  countable    :boolean
#  description  :string
#  damage       :integer
#  damage_dice  :integer
#  cost         :integer
#  damage_type  :integer
#  weight       :integer
#  is_fencing   :boolean          default("0")
#  is_universal :boolean          default("0")
#  is_twohand   :boolean          default("0")
#  is_throwable :boolean          default("0")
#

class Weapon < ActiveRecord::Base
  has_many :weaponings, inverse_of: :item

  def short_description
    "#{weight}фнт. #{damage}d#{damage_dice} #{damage_type} #{description}"
  end
end

    # "name": "Боевой посох",
    # "cost": 20,
    # "damage": "1",
    # "damage_dice": "6",
    # "damage_type": "дробящий",
    # "weight": 4,
    # "description": "Универсальное (1d8)"
