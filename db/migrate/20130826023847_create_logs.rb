class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.references :user, index: true
      t.integer :loggable_id
      t.integer :loggable_type

      t.string :action
      t.timestamps
    end
  end
end
