class AddDefaultCategoryIdToDepartmentConfigs < ActiveRecord::Migration
  def self.up
    add_column :department_configs, :default_category_id, :integer
  end

  def self.down
    remove_column :department_configs, :default_category_id
  end
end
