# == Schema Information
#
# Table name: masters
#
#  id           :integer          not null, primary key
#  name         :string
#  adventure_id :integer
#  user_id      :integer
#
class Master < ActiveRecord::Base
  validates_presence_of :name

  belongs_to :user
  belongs_to :adventure
end
