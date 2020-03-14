class FightGroup < ActiveRecord::Base
  belongs_to :adventure

  has_many   :non_players, dependent: :destroy

  def self.to_fight fight
    non_players.each do |f|
      new_fighter = f.dup
      new_fighter.fight_group = nil
      fight << new_fighter
    end
  end
end
