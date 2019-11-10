class CreateMasterTable < ActiveRecord::Migration[6.0]
  def change
    create_table :masters do |t|
      t.string :name
      t.belongs_to :adventure
      t.belongs_to :user
    end
  end
end
