# == Schema Information
#
# Table name: skills
#
#  id   :integer          not null, primary key
#  name :string
#  base :integer
#
class Skill < ActiveRecord::Base
  has_many :skilling

  def short_description
    "#{name} (#{t("char.#{Player::MODS[base]}")})"
  end
end
