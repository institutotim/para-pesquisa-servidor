class CreateStopReasons < ActiveRecord::Migration
  def change
    create_table :stop_reasons do |t|
      t.string :reason
      t.boolean :reschedule, default: false
      t.references :form, index: true

      t.timestamps
    end
  end
end
