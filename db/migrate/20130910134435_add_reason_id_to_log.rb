class AddReasonIdToLog < ActiveRecord::Migration
  def change
    add_column :logs, :reason_id, :integer, index: true
  end
end
