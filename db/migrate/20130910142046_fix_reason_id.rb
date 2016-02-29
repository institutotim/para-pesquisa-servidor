class FixReasonId < ActiveRecord::Migration
  def change
    rename_column :logs, :reason_id, :stop_reason_id
  end
end
