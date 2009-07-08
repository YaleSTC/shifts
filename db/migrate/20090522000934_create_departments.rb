class CreateDepartments < ActiveRecord::Migration
  def self.up
    create_table :departments do |t|
      t.string :name
      t.references :admin_permission
      t.references :payforms_permission
      t.references :shifts_permission
      t.timestamps
    end
  end

  def self.down
    drop_table :departments
  end
end

