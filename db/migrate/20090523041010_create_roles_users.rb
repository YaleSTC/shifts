class CreateRolesUsers < ActiveRecord::Migration
  def self.up
    create_table "roles_users", :id => false, :force => true do |t|
      t.integer "role_id", :limit => 10, :default => 0, :null => false
      t.integer "user_id",       :limit => 10, :default => 0, :null => false
    end

    add_index "roles_users", ["role_id", "user_id"], :name => "roles_users_FKIndex1", :unique => true
    add_index "roles_users", ["user_id"], :name => "roles_users_FKIndex2"
  end

  def self.down
    drop_table :roles_users
  end
end

