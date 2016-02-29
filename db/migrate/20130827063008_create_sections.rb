class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :name
      t.integer :order
      t.references :form, :index => true

      t.timestamps
    end
  end
end
