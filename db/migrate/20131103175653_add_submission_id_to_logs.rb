class AddSubmissionIdToLogs < ActiveRecord::Migration
  def change
    remove_column :logs, :loggable_type
    rename_column :logs, :loggable_id, :submission_id
  end
end
