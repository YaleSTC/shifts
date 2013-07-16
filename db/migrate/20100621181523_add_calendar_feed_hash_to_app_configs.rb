class AddCalendarFeedHashToAppConfigs < ActiveRecord::Migration
  def self.up
      add_column :app_configs, :calendar_feed_hash, :string
  end

  def self.down
      remove_column :app_configs, :calendar_feed_hash
  end
end
