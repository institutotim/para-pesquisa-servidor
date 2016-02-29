class RemoveDefaultValueFromAllowNewSubmissionsAttribute < ActiveRecord::Migration
  def change
    change_column :forms, :allow_new_submissions, :boolean, default: nil
  end
end
