# == Schema Information
#
# Table name: fights
#
#  id           :integer          not null, primary key
#  adventure_id :integer
#  current_step :integer          default("0")
#  fase         :integer          default("0")
#
class Fight < ActiveRecord::Base
  belongs_to :adventure

  has_many   :non_players

  STATES = {0 => :init, 1 => :roll_init, 2 => :fight, 3 => :finish}

  def ready
    STATES[self.fase]==0
  end

  def active
    STATES[self.fase]==2
  end

  def finish
    STATES[self.fase]==3
  end

  def self.make_fight opts
    add_players = opts.delete :add_players
    add_players = true if add_players.nil?

    f = self.create opts
    f.adventure.players.each do |p|
      p.is_fighter = add_players
      p.save
    end
    f.active = false
    f.ready  = true
    f.finished = false
    f.save
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

  # TODO: take is_master in account... do not show some fields to players
  def get_fighters(is_master,locale='ru')
    I18n.locale = locale
    players = adventure.players
      .where(is_master: false, is_fighter: true).includes(:race)
      .map { |e|
        {
          name: e.name, id: e.id, race: I18n.t("char.#{e.race.name}"),
          hp: e.hp, max_hp: e.max_hp, initiative: e.get_char(:initiative) || 0,
          armor_class: e.get_char(:armor_class) || 0, step_order: e.step_order,
          is_npc: false
        }
      }
    fighters = non_players.all.map { |e|
      {
        name: e.name, id: e.id, race: I18n.t("char.#{e.race.name}"),
        hp: e.hp, max_hp: e.max_hp, initiative: e.initiative || 0,
        armor_class: e.armor_class, step_order: e.step_order || 0,
        is_npc: true
      }
    }
    players+fighters
  end
end
