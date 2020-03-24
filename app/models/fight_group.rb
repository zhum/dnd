# == Schema Information
#
# Table name: fight_groups
#
#  id           :integer          not null, primary key
#  adventure_id :integer
#  name         :string
#
class FightGroup < ActiveRecord::Base
  belongs_to :adventure

  has_many   :non_players, dependent: :destroy

  def to_fight fight
    non_players.each do |f|
      new_fighter = f.dup
      new_fighter.fight_group = nil
      fight.non_players << new_fighter
    end
  end
end
