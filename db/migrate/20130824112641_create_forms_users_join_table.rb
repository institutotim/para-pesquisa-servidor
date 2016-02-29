class CreateFormsUsersJoinTable < ActiveRecord::Migration
  create_table :forms_users, id: false do |t|
    t.integer :user_id
    t.integer :form_id
  end
end
