class CreateDepartmentsUsers < ActiveRecord::Migration
  def self.up
    create_table :departments_users, :id => false do |t|
      t.references :department
      t.references :user
      t.boolean :deactivated, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :departments_users
  end
end

