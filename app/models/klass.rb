# == Schema Information
#
# Table name: klasses
#
#  id          :integer          not null, primary key
#  name        :string
#  description :string
#
class Klass < ActiveRecord::Base
  has_many :players
end
