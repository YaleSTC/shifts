class CreateRolesUsers < ActiveRecord::Migration
  def self.up
    create_table :roles_users, :id => false do |t|
      t.references :role
      t.references :user
    end
  end

  def self.down
    drop_table :roles_users
  end
end

