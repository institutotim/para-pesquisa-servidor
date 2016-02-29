class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.boolean :substitution, :default => false
      t.string :status
      t.text :answers
      t.text :corrections
      t.references :assignment
      t.references :user, :index => true
      t.references :form, :index => true

      t.datetime :started_at
      t.timestamps
    end
  end
end
