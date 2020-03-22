# == Schema Information
#
# Table name: adventures
#
#  id     :integer          not null, primary key
#  name   :string
#  opened :boolean
#
class Adventure < ActiveRecord::Base
  has_many :players
  #has_one  :master, class_name: 'Player'
  has_many :fights
  has_many :fight_groups

  def active_fight
    fights.active.take
  end

  def ready_fight
    fights.ready.take
  end
  
  def finished_fight
    fights.finished.take
  end
  
  def master
    self.players.where(is_master: true).take
  end
end
