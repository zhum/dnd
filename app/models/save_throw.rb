class SaveThrow < ActiveRecord::Base
  belongs_to :player

  # kind  (int)  1=проваленный от смерти, 2=успешный от смерти
  # count (int)
end