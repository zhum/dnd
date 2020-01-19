class Spelling < ActiveRecord::Base
  belongs_to :player
  belongs_to :spell
end