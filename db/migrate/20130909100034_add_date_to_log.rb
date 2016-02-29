class AddDateToLog < ActiveRecord::Migration
  def change
    add_column :logs, :date, :datetime
  end
end
