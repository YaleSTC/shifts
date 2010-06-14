class AddInactiveShiftStatus < ActiveRecord::Migration
  def self.up
    add_column :department_configs, :inactive_shift, :boolean, :default => true    
  end

  def self.down
    remove_column :department_configs, :inactive_shift 
  end
end
