class CreateFeaturings < ActiveRecord::Migration[6.0]
  def change
    create_table :featurings do |t|
      t.belongs_to :player
      t.belongs_to :feature

      t.integer    :count
    end
  end
end
