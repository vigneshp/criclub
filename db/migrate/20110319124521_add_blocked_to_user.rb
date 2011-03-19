class AddBlockedToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :blocked, :string
    add_column :users, :blocked_time , :datetime
    add_column :users, :blocked_period , :int
  end

  def self.down
    
  end
end
