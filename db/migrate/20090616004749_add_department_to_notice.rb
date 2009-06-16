class AddDepartmentToNotice < ActiveRecord::Migration
  def self.up
    add_column :notices, :department, :integer
  end

  def self.down
    remove_column :notices, :department
  end
end
