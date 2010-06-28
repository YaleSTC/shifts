class AddCalendarFeedHashToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :calendar_feed_hash, :string
  end

  def self.down
    remove_column :users, :calendar_feed_hash
  end
end
