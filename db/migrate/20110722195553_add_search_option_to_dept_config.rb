class AddSearchOptionToDeptConfig < ActiveRecord::Migration
  def self.up
    add_column :department_configs, :search_engine_name, :string, default: "Google"
    add_column :department_configs, :search_engine_url, :string, default: "http://www.google.com/search?q="
  end

  def self.down
    remove_column :department_configs, :search_engine_name
    remove_column :department_configs, :search_engine_url
  end
end
