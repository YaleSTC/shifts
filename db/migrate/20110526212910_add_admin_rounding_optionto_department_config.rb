class AddAdminRoundingOptiontoDepartmentConfig < ActiveRecord::Migration
  def self.up
    add_column :department_configs, :admin_round_option, :integer, :default => 15
  end

  def self.down
    add_column :department_configs, :admin_round_option
  end
end
