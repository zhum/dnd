class DeleteEmailFromPlayer < ActiveRecord::Migration[6.0]
  def change
    change_table :players do |t|
      t.remove  :email
    end
  end
end
