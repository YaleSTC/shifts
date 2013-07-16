class AddAdminLeniencyPreferenceToTasks < ActiveRecord::Migration
  def self.up
    add_column :department_configs, :task_leniency, :integer, :default => 60
  end

  def self.down
    remove_column :department_configs, :task_leniency, :integer
  end
end
