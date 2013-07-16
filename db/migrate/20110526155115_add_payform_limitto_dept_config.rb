class AddPayformLimittoDeptConfig < ActiveRecord::Migration
  def self.up
    add_column :department_configs, :payform_time_limit, :integer
  end

  def self.down
    remove_column :department_configs, :payform_time_limit
  end
end
