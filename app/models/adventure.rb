class Adventure < ActiveRecord::Base
  has_many :players
  has_one  :master, class_name: 'Player'
end