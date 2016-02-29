class CreateSubmissionsAlternativesJoinTable < ActiveRecord::Migration
  create_table :alternatives_submissions, id: false do |t|
    t.integer :submission_id
    t.integer :alternative_id
  end
end
