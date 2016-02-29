class CreateSubmissionsSubstitutionsJoinTable < ActiveRecord::Migration
  create_table :submissions_substitutions, id: false do |t|
    t.integer :user_id
    t.integer :substitution_id
  end
end
