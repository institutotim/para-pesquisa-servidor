class AddAllowTransferToForms < ActiveRecord::Migration
  def change
    add_column :forms, :allow_transfer, :boolean, default: true
  end
end
