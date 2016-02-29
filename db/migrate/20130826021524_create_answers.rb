class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.references :field, index: true
      t.references :submission, index: true

      t.timestamps
    end
  end
end
