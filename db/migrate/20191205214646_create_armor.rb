class CreateArmor < ActiveRecord::Migration[6.0]
  def change
    create_table :armors do |t|
      t.string   :name
      t.boolean  :bad_stealth
      t.integer  :weight
      t.integer  :cost
      t.integer  :klass
      t.boolean  :add_sleight
      t.string   :description
    end
  end
end
