class CreateSkills < ActiveRecord::Migration[6.0]
  def change
    create_table :skills do |t|
      t.string    :name
      t.integer   :base
    end

#    create_table :skilling do |t|
#      t.belongs_to :player
#      t.belongs_to :skill
#
#      t.boolean    :ready
#      t.integer    :modifier
#    end
  end
end
