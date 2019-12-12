class CreatePrefs < ActiveRecord::Migration[6.0]
  def change
    create_table :prefs do |t|
      t.belongs_to :player
      t.string     :name
      t.string     :value
    end
  end
end
