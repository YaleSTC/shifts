class AddCanTakePassedSubToDepartmentConfig < ActiveRecord::Migration
  def self.up
    add_column :department_configs, :can_take_passed_sub, :boolean, default: true
  end

  def self.down
    remove_column :department_configs, :can_take_passed_sub
  end
end
