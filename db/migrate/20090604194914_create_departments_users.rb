class CreateDepartmentsUsers < ActiveRecord::Migration
  def self.up
    create_table :departments_users, id: false do |t|
      t.references :department
      t.references :user
      t.boolean :active, default: true

      t.timestamps #TODO: do we want to track when a user was added to a particular departmenet?
    end
  end

  def self.down
    drop_table :departments_users
  end
end

