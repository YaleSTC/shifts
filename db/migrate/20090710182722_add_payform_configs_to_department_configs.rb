class AddPayformConfigsToDepartmentConfigs < ActiveRecord::Migration
  def self.up
    add_column :department_configs, :printed_message, :text
    add_column :department_configs, :reminder_message, :text
    add_column :department_configs, :warning_message, :text
    add_column :department_configs, :warning_weeks, :integer
    add_column :department_configs, :description_min, :integer
    add_column :department_configs, :reason_min, :integer
    add_column :department_configs, :punch_clock, :boolean
  end

  def self.down
    remove_column :department_configs, :punch_clock
    remove_column :department_configs, :reason_min
    remove_column :department_configs, :description_min
    remove_column :department_configs, :warning_weeks
    remove_column :department_configs, :warning_message
    remove_column :department_configs, :reminder_message
    remove_column :department_configs, :printed_message
  end
end

