class AddRequiresApprovalOnForm < ActiveRecord::Migration
  def change
    add_column :forms, :requires_approval, :boolean, default: false
  end
end
