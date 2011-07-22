class AddSearchOptionToDeptConfig < ActiveRecord::Migration
  def self.up
    add_column :department_configs, :seach_engine_name, :string
    add_column :department_configs, :seach_engine_url, :string
  end

  def self.down
    remove_column :department_configs, :seach_engine_name
    remove_column :department_configs, :seach_engine_url
  end
end
