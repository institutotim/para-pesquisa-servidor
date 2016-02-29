class AddDefaultValueToAllowNewSubmissionsAttribute < ActiveRecord::Migration
  def change
    change_column :forms, :allow_new_submissions, :boolean, default: true
  end
end
