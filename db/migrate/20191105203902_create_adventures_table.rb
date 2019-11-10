class CreateAdventuresTable < ActiveRecord::Migration[6.0]
  def change
    create_table :adventures do |t|
      t.string :name
    end

    change_table :players do |t|
      t.belongs_to :adventure
    end
  end
end
