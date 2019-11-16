class Player < ActiveRecord::Base
  validates_presence_of :name

  has_many :resources
  has_many :chars
  belongs_to :user
  belongs_to :adventure

  def to_json
    h = ['id', 'name', 'klass', 'race', 'hp'].map{|name|
      [name, self.public_send(name)]
    }
    h << ['coins',[mcoins,scoins,gcoins,ecoins,pcoins]]
    h << ['chars',Hash[chars.map{|c| [c.name,c.value]}]]
    warn "===> #{h.inspect}"
    Hash[h].to_json.to_s
    
  end
end