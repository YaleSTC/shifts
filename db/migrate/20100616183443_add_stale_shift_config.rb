class AddStaleShiftConfig < ActiveRecord::Migration
  def self.up
    add_column :department_configs, :stale_shift, :boolean, :default => true
  end

  def self.down
    remove_column :department_configs, :stale_shift
  end
end
