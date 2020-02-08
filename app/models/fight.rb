class Fight < ActiveRecord::Base
  belongs_to :adventure

  has_many   :non_players


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

  def get_fighters(locale='ru')
    I18n.locale = locale
    players = adventure.players
      .where(is_master: false).includes(:race)
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