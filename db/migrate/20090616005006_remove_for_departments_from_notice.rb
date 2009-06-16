class RemoveForDepartmentsFromNotice < ActiveRecord::Migration
  def self.up
    remove_column :notices, :for_departments
  end

  def self.down
    add_column :notices, :for_departments, :string
  end
end
