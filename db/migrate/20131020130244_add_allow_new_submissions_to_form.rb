class AddAllowNewSubmissionsToForm < ActiveRecord::Migration
  def change
    add_column :forms, :allow_new_submissions, :boolean, default: true
  end
end
