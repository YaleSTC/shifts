class AddShiftViewPrefsToDepartmentConfig < ActiveRecord::Migration
  def self.up
    add_column :department_configs, :weekend_shifts, :boolean
    add_column :department_configs, :unscheduled_shifts, :boolean
  end

  def self.down
    remove_column :department_configs, :unscheduled_shifts
    remove_column :department_configs, :weekend_shifts
  end
end

