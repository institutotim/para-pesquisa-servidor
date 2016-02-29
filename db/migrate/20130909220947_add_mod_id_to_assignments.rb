class AddModIdToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :mod_id, :integer, index: true
  end
end
