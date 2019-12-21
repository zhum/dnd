class ChangePlayerDefaults < ActiveRecord::Migration[6.0]
  def change
    change_column_default :players, :hp, to: 20
    change_column_default :players, :max_hp, to: 20
    change_column_default :players, :mcoins, to: 0
    change_column_default :players, :scoins, to: 0
    change_column_default :players, :gcoins, to: 0
    change_column_default :players, :ecoins, to: 0
    change_column_default :players, :pcoins, to: 0
    change_column_default :players, :is_master, to: false
    change_column_default :players, :mod_strength, to: 0
    change_column_default :players, :mod_dexterity, to: 0
    change_column_default :players, :mod_constitution, to: 0
    change_column_default :players, :mod_intellegence, to: 0
    change_column_default :players, :mod_wisdom, to: 0
    change_column_default :players, :mod_charisma, to: 0
    change_column_default :players, :experience, to: 0
  end
end
