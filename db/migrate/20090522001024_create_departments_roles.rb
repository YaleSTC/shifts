class CreateDepartmentsRoles < ActiveRecord::Migration
  def self.up
    create_table :departments_roles, :id => false do |t|
      t.references :department
      t.references :role
    end
  end

  def self.down
    drop_table :departments_roles
  end
end

