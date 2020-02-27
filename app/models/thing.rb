# == Schema Information
#
# Table name: things
#
#  id     :integer          not null, primary key
#  name   :string
#  cost   :integer
#  weight :integer
#
class Thing < ActiveRecord::Base
  has_many :thingings

  def short_description
    "#{weight}фнт."
  end
end
