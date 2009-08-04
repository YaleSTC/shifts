class CreatePermissionsRoles < ActiveRecord::Migration
  def self.up
    create_table :permissions_roles do |t|
      t.references :role
      t.references :permission
    end
  end

  def self.down
    drop_table :permissions_roles
  end
end

