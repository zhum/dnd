class CreateFight < ActiveRecord::Migration[6.0]
  def change
    create_table :fights do |t|
      t.belongs_to :adventure
    end
  end
end
