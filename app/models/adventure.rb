class Adventure < ActiveRecord::Base
  has_many :players
  #has_one  :master, class_name: 'Player'
  def master
    self.players.where(is_master: true).take
  end
end