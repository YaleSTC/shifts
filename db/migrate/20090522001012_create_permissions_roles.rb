class CreatePermissionsRoles < ActiveRecord::Migration
  def self.up
    create_table "permissions_roles", :id => false, :force => true do |t|
      t.integer "role_id",       :limit => 10, :default => 0, :null => false
      t.integer "permission_id", :limit => 10, :default => 0, :null => false
    end

    add_index "permissions_roles", ["permission_id", "role_id"], :name => "permissions_roles_FKIndex1", :unique => true
    add_index "permissions_roles", ["role_id"], :name => "permissions_roles_FKIndex2"
  end

  def self.down
    drop_table :permissions_roles
  end
end

