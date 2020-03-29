# == Schema Information
#
# Table name: non_players
#
#  id                 :integer          not null, primary key
#  npc_type_id        :integer
#  fight_id           :integer
#  name               :string
#  max_hp             :integer
#  hp                 :integer
#  armor_class        :integer
#  initiative         :integer
#  step_order         :integer
#  pass_attentiveness :integer          default("0")
#  is_dead            :boolean          default("0")
#  fight_group_id     :integer
#

class NonPlayer < ActiveRecord::Base
  validates_presence_of :name
  belongs_to :npc_type
  belongs_to :fight
  belongs_to :fight_group
  has_many :npc_things, dependent: :destroy
  has_many :npc_armors, dependent: :destroy
  has_many :npc_weapons, dependent: :destroy

  def self.generate npc_type, fight_group
    name = "#{npc_type.name} #{get_next_id(fight_group,npc_type)}"
    logger.warn "name=#{name}"
    f = fight_group.is_a?(Fight) ? fight_group : nil
    npc = create!(
      npc_type: npc_type, fight: f, name: name,
      max_hp: npc_type.max_hp, hp: make_hp(npc_type),
      armor_class: npc_type.armor_class,
      initiative: rand(20)+1+npc_type.initiative,
      pass_attentiveness: npc_type.pass_attentiveness,
      step_order: 1)
    npc.npc_weapons << NpcWeapon.create(weapon: Weapon.find_by_name('Боевой посох'))
    npc.save
    npc
  end

  def self.get_next_id fight_group, npc_type
    count = fight_group.non_players.where(npc_type_id: npc_type.id).count
    count+1
  end

  def self.make_hp npc_type
    max_hp = npc_type.max_hp

    max_hp/2 + rand(max_hp/2+1)
  end

  def race
    self.npc_type
  end

  def to_hash
    {
      npc_type: npc_type.name, name: name,
      id: id,
      max_hp: max_hp, hp: hp,
      armor_class: armor_class,
      initiative: initiative,
      pass_attentiveness: pass_attentiveness,
      step_order: step_order
    }
  end
end
