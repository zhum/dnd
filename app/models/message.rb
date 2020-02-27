# == Schema Information
#
# Table name: messages
#
#  id         :integer          not null, primary key
#  text       :string
#  player_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  to_master  :boolean
#
class Message < ActiveRecord::Base
  belongs_to :player
  # text
end
