class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer :quota, default: 0
      t.references :form, :index => true
      t.references :user, :index => true

      t.timestamps
    end
  end
end
