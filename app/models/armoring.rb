class Armoring < ActiveRecord::Base
  belongs_to :player
  belongs_to :armor
end