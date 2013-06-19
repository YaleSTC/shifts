class AddDepartmentWideToNotices < ActiveRecord::Migration
  def self.up
    add_column :notices, :department_wide, :boolean
  end

  def self.down
    remove_column :notices, :department_wide
  end
end
