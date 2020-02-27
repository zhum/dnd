# == Schema Information
#
# Table name: skillings
#
#  id        :integer          not null, primary key
#  player_id :integer
#  skill_id  :integer
#  ready     :boolean
#  modifier  :integer
#
class Skilling < ActiveRecord::Base
  belongs_to :skill
  belongs_to :player

  #ready
  #modificator
  def value
    # 'strength','dexterity','constitution',
    # 'intellegence','wisdom','charisma'

    val = ((player.get_mod skill.base)-10) / 2

    if self.ready
      val += player.get_char(:masterlevel).to_i
    end
    return val
  end
end
