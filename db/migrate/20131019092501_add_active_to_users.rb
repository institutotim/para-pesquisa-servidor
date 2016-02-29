class AddActiveToUsers < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :users do |t|
        dir.up { t.boolean :active, default: true }
        dir.down { t.remove :active }
      end
    end
  end
end
