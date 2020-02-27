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

  def active_fight
    fights.where(active: true).take
  end

  def ready_fight
    fights.where(ready: true).take
  end
  
  def master
    self.players.where(is_master: true).take
  end
end
