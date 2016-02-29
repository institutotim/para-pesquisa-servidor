class ChangeLogLoggableType < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :logs do |t|
        dir.up { t.change :loggable_type, :string }
        dir.down { t.change :loggable_type, :integer }
      end
    end
  end
end
