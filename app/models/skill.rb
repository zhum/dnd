class Skill < ActiveRecord::Base
  has_many :skilling

  def short_description
    "#{name} (#{t("char.#{Player::MODS[base]}")})"
  end
end