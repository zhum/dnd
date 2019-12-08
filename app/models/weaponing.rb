# integer count
# integer max_count

class Weaponing < ActiveRecord::Base
  belongs_to :player
  belongs_to :weapon
end
