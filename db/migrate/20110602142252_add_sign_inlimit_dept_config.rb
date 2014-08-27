class AddSignInlimitDeptConfig < ActiveRecord::Migration
  def self.up
    add_column :department_configs, :early_signin, :integer, default: 60
  end

  def self.down
    remove_column :department_configs, :early_signin
  end
end
