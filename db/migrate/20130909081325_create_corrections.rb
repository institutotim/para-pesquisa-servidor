class CreateCorrections < ActiveRecord::Migration
  def change
    create_table :corrections do |t|
      t.references :field, :index => true
      t.text :message
      t.references :user, :index => true
      t.references :submission, :index => true

      t.timestamps
    end
  end
end
