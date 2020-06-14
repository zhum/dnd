# frozen_string_literal: false

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
#

# Fight class
#
# @author [serg]
#
class Fight < ActiveRecord::Base
  belongs_to :adventure

  has_many   :non_players, dependent: :delete_all

  STATES = {
    0 => :init,
    1 => :roll_init,
    2 => :fight,
    3 => :finish,
    4 => :deleted
  }.freeze

  scope :active, lambda {
    where fase: [1, 2]
  }

  scope :ready, lambda {
    where fase: 0
  }

  scope :finished, lambda {
    where fase: 3
  }

  def ready?
    STATES[fase] == :init
  end

  def active?
    STATES[fase] == :fight
  end

  def finish?
    STATES[fase] == :finish
  end

  def finish
    fase = 3
    save!
  end

  def delete
    #self.non_players.destroy
    destroy
  end

  def self.make_fight(opts)
    do_add_players = opts.delete :add_players
    do_add_players = true if do_add_players.nil?

    logger.warn "make_fight (#{do_add_players})"
    f = create opts
    f.add_players if do_add_players
    f.fase = 0
    f.fighter_index = 0
    f.current_step = 0
    f.save
    f.update_step_orders
    f
  end

  def update_step_orders
    players = adventure
              .players
              .where(is_master: false)
              .map do |e|
                { player: e, initiative: (e.real_initiative || -1) }
              end
    fighters = non_players.all.map do |e|
      { player: e, initiative: e.initiative }
    end
    step = 1
    (players + fighters).sort_by { |x| -x[:initiative].to_i }.each do |x|
      x[:player].step_order = step
      x[:player].save
      step += 1
    end
  end

  # TODO: take is_master into account... do not show some fields to players
  def get_fighters(is_master, locale = :ru)
    I18n.locale = locale
    f = adventure.players.map { |e| "#{e.name}/#{e.is_fighter}" }.join(';')
    logger.warn "get_fighters: #{f}"
    players = adventure
              .players
              .where(is_master: false)
              .includes(:race)
              .map do |e|
                {
                  is_fighter: e.is_fighter,
                  name: e.name, id: e.id,
                  race_id: e.race.id, race: I18n.t("char.#{e.race.name}"),
                  hp: e.hp, max_hp: e.max_hp,
                  initiative: (e.real_initiative || -1),
                  # get_char(:initiative) || 0,
                  armor_class: e.get_char(:armor_class) || 0,
                  step_order: e.step_order,
                  is_npc: false
                }
              end
    fighters = non_players.all.map do |e|
      # logger.warn "#{e.inspect}"
      # logger.warn "#{e.race.inspect}"
      {
        is_fighter: !e.is_dead,
        name: e.name, id: e.id, race_id: e.race.id,
        race: e.race.name,
        # e.race.is_tmp ? e.race.name : e.race.name,
        # I18n.t("char.#{e.race.name}"),
        hp: e.hp, max_hp: e.max_hp, initiative: e.initiative || 0,
        armor_class: e.armor_class, step_order: e.step_order || 0,
        is_npc: true
      }
    end
    players + fighters
  end

  def add_players
    adventure.players.each do |p|
      logger.warn "+ #{p.name}"
      p.is_fighter = true
      p.real_initiative = -1
      p.save
    end
  end

  def kill_npc(opts)
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

  def shift_list_tail(index)
    (players + non_players).where('step_order > ?', index).each do |p|
      p.step_order -= 1
      p.save
    end
  end
end
