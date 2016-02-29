class AddOrderToForms < ActiveRecord::Migration
  def change
    add_column :forms, :order, :integer
  end
end
