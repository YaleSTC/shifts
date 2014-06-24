class AddExpiredColumntoTasksTable < ActiveRecord::Migration
  def self.up
    add_column :tasks, :expired, :boolean, default: false 
  end

  def self.down
    remove_column :tasks, :expired, :boolean
  end
end
