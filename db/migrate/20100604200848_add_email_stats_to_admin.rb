class AddEmailStatsToAdmin < ActiveRecord::Migration
  def self.up
    add_column :department_configs, :email_stats, :boolean, :default => true    
  end

  def self.down
    remove_column :department_configs, :email_stats    
  end
end
