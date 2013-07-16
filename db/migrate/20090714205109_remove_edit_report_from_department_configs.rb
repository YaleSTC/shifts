class RemoveEditReportFromDepartmentConfigs < ActiveRecord::Migration
  def self.up
    remove_column :department_configs, :edit_report
    remove_column :department_configs, :punch_clock
  end

  def self.down
    add_column :department_configs, :edit_report, :boolean
    add_column :department_configs, :punch_clock, :boolean
  end
end

