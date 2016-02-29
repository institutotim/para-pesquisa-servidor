class CreateForms < ActiveRecord::Migration
  def change
    create_table :forms do |t|
      t.string :name
      t.string :subtitle
      t.integer :quota, default: 0
      t.integer :max_reschedules, default: 0
      t.boolean :restricted_to_users
      t.datetime :pub_start
      t.datetime :pub_end

      t.timestamps
    end
  end
end
