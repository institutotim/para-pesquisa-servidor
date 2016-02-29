class CreateOptions < ActiveRecord::Migration
  def change
    create_table :choices do |t|
      t.string :label
      t.string :value
      t.references :field, :index => true
    end
  end
end
