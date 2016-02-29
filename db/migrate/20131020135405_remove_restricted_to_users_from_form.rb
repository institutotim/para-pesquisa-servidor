class RemoveRestrictedToUsersFromForm < ActiveRecord::Migration
  def change
    remove_column :forms, :restricted_to_users
  end
end
