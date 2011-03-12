class MyNewMigration < ActiveRecord::Migration
  def self.up
    rename_column :comments , :body , :content
    rename_column :comments , :name , :user_id
  end

  
end
