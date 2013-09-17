class RenameNoticesStartTimeEndTimeToStartEnd < ActiveRecord::Migration
  def self.up
		rename_column :notices, :start_time, :start
		rename_column :notices, :end_time, :end
  end

  def self.down
		rename_column :notices, :start, :start_time
		rename_column :notices, :end, :end_time
  end
end
