class Thing < ActiveRecord::Base
  has_many :thingings

  def short_description
    "#{weight}фнт."
  end
end