class CreateDepartmentsUsers < ActiveRecord::Migration
  def self.up
    create_table "departments_users", :id => false, :force => true do |t|
      t.integer "department_id", :limit => 10, :default => 0, :null => false
      t.integer "user_id",       :limit => 10, :default => 0, :null => false
      t.boolean "deactivated", :default => false
    end

    add_index "departments_users", ["department_id", "user_id"], :name => "departments_users_FKIndex1", :unique => true
    add_index "departments_users", ["user_id"], :name => "departments_users_FKIndex2"
  end

  def self.down
    drop_table :departments_users
  end
end