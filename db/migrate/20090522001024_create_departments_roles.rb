class CreateDepartmentsRoles < ActiveRecord::Migration
  def self.up
    create_table "departments_roles", :id => false, :force => true do |t|
      t.integer "department_id", :limit => 10, :default => 0, :null => false
      t.integer "role_id",       :limit => 10, :default => 0, :null => false
    end

    add_index "departments_roles", ["department_id", "role_id"], :name => "departments_roles_FKIndex1", :unique => true
    add_index "departments_roles", ["role_id"], :name => "departments_roles_FKIndex2"
  end

  def self.down
    drop_table :departments_roles
  end
end