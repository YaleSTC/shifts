class AddPayrateToDepartmentsUser < ActiveRecord::Migration
  def self.up
    add_column :departments_users, :payrate, :decimal, precision: 10, scale: 2
  end

  def self.down
    remove_column :departments_users, :payrate
  end
end
