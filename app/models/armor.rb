class Armor < ActiveRecord::Base
  has_many :armoring

  def short_description
    "#{weight}фнт. #{klass}кл. #{description}"
  end
end