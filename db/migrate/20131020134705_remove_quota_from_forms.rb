class RemoveQuotaFromForms < ActiveRecord::Migration
  def change
    remove_column :forms, :quota
  end
end
