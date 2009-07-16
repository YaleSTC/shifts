class RemoveEditReportFromDepartmentConfigs < ActiveRecord::Migration
  def self.up
    remove_column :department_configs, :edit_report
    remove_column :department_configs, :punch_clock
    remove_column :department_configs, :complex
    remove_column :department_configs, :day2
  end

  def self.down
    add_column :department_configs, :edit_report, :boolean
    add_column :department_configs, :punch_clock, :boolean
    add_column :department_configs, :complex, :boolean
    add_column :department_configs, :day2, :integer
  end
end

