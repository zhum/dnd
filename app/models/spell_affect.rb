class SpellAffect < ActiveRecord::Base
  belongs_to :spelling
  belongs_to :player
  belongs_to :owner, class_name: "Player", foreign_key: "owner_id"
end