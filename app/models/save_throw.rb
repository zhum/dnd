# == Schema Information
#
# Table name: save_throws
#
#  id        :integer          not null, primary key
#  kind      :integer
#  count     :integer
#  player_id :integer
#
class SaveThrow < ActiveRecord::Base
  belongs_to :player

  # kind  (int)  1=проваленный от смерти, 2=успешный от смерти
  # count (int)
end
