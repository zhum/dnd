# == Schema Information
#
# Table name: fights
#
#  id            :integer          not null, primary key
#  adventure_id  :integer
#  current_step  :integer          default("0")
#  fase          :integer          default("0")
#  fighter_index :integer
#
class Fight < ActiveRecord::Base
  belongs_to :adventure

  has_many   :non_players, dependent: :destroy

  STATES = {0 => :init, 1 => :roll_init, 2 => :fight, 3 => :finish}

  scope :active, -> {
    where fase: [1,2]
  }

  scope :ready, -> {
    where fase: 0
  }

  def is_ready?
    STATES[self.fase]==0
  end

  def is_active?
    STATES[self.fase]==2
  end

  def is_finish?
    STATES[self.fase]==3
  end

  def finish
    self.fase = 3
    save!
  end

  def self.make_fight opts
    do_add_players = opts.delete :add_players
    do_add_players = true if do_add_players.nil?

    logger.warn "make_fight (#{do_add_players})"
    f = self.create opts
    f.add_players if do_add_players
    f.fase = 0
    f.fighter_index = 0
    f.current_step = 0
    f.save
    f.update_step_orders
    f
  end

  def update_step_orders
    players = adventure.players
      .where(is_master: false)
      .map { |e| {player: e, initiative: e.get_char(:initiative)}}
    fighters = non_players.all.map { |e| {player: e, initiative: e.initiative}}
    step = 1
    (players+fighters).sort_by{|x| -x[:initiative].to_i}.each{|x|
      x[:player].step_order = step
      x[:player].save
      step += 1
    }
  end

  # TODO: take is_master into account... do not show some fields to players
  def get_fighters(is_master,locale='ru')
    I18n.locale = locale
    logger.warn "get_fighters: "+adventure.players.map { |e| "#{e.name}/#{e.is_fighter}"}.join(';')
    players = adventure.players
      .where(is_master: false)
      .includes(:race)
      .map { |e|
        {
          is_fighter: e.is_fighter,
          name: e.name, id: e.id, race_id: e.race.id, race: I18n.t("char.#{e.race.name}"),
          hp: e.hp, max_hp: e.max_hp, initiative: e.get_char(:initiative) || 0,
          armor_class: e.get_char(:armor_class) || 0, step_order: e.step_order,
          is_npc: false
        }
      }
    fighters = non_players.all.map { |e|
      {
        is_fighter: !e.is_dead,
        name: e.name, id: e.id, race_id: e.race.id, race: I18n.t("char.#{e.race.name}"),
        hp: e.hp, max_hp: e.max_hp, initiative: e.initiative || 0,
        armor_class: e.armor_class, step_order: e.step_order || 0,
        is_npc: true
      }
    }
    players+fighters
  end

  def add_players
    self.adventure.players.each do |p|
      logger.warn "+ #{p.name}"
      p.is_fighter = true
      p.save
    end
  end

  def kill_npc opts
    f = nil
    i = -1
    if opts[:index]
      i = opts[:index]
      f = non_players.find_by_step_order i
    elsif opts[:npc]
      f = non_players.find_by_id opts[:npc].id
      i = f.step_order
    else
      raise "Bad args for kill_npc (#{opts})"
    end
    f.is_dead = true
    f.save
    shift_list_tail i
  end

  def shift_list_tail index
    (players+non_players).where("step_order > ?", index).each{ |p|
      p.step_order -= 1
      p.save
    }
  end
end
