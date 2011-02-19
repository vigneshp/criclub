class AddAccesstokToUser < ActiveRecord::Migration
  def self.up
#  add_accesstok :users
     change_table :users do |t|
      #t.accesstok  # add ':unique => true' option if necessary
    end
  end

  def self.down
#  remove_accesstok :users 
  end
end
