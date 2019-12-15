class Skilling < ActiveRecord::Base
  belongs_to :skill
  belongs_to :player

  #ready
  #modificator
end