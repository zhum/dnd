class Adventure < ActiveRecord::Base
  has_many :players
  has_one  :master
end