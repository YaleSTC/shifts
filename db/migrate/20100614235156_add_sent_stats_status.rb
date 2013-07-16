class AddSentStatsStatus < ActiveRecord::Migration
  def self.up
      add_column :shifts, :stats_unsent, :boolean, :default => true    
    end

    def self.down
      remove_column :shifts, :stats_unsent
    end
end
