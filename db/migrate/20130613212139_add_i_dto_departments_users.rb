class AddIDtoDepartmentsUsers < ActiveRecord::Migration
  def self.up
  	 add_column :departments_users, :id, :primary_key
  end

  def self.down
  	remove_column :departments_users, :id
  end
end
