# == Schema Information
#
# Table name: features
#
#  id          :integer          not null, primary key
#  name        :string
#  description :string
#  max_count   :integer
#
class Feature < ActiveRecord::Base
  has_many :featuring, inverse_of: :item

  #max_count
end
