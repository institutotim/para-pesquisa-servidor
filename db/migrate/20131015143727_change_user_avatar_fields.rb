class ChangeUserAvatarFields < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :users do |t|
        dir.up do
          [:avatar_content_type, :avatar_file_size, :avatar_updated_at, :avatar_file_name].each { |column_to_remove| t.remove(column_to_remove) if User.column_names.include?(column_to_remove.to_s) }
          t.string :avatar
        end

        dir.down do
          t.string :avatar_file_name, :avatar_content_type
          t.integer :avatar_file_size
          t.datetime :avatar_updated_at
        end
      end
    end
  end
end
