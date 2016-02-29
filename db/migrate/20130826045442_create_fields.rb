class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.string :label
      t.string :description
      t.string :type
      t.string :layout
      t.boolean :read_only, :default => false
      t.boolean :identifier, :default => false
      t.text :validations
      t.text :actions
      t.integer :order
      t.boolean :public, :default => true
      t.references :section, index: true

      t.timestamps
    end
  end
end
