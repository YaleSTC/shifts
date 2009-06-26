class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login
      t.string :first_name
      t.string :last_name
      t.string :nick_name
      t.string :employee_id #optional, but pretty standard, and can be used under any id system (not just Yale)
      t.string :email
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token
      t.string :auth_type
      t.string :perishable_token, :default => "", :null =>false
      t.references :default_department
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
