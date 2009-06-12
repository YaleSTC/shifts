class CreateDepartments < ActiveRecord::Migration
  def self.up
    create_table :departments do |t|
      t.string :name
      t.references :permission
      t.references :payform_permission

      #Payform Configuration
      #=========================
      t.boolean  :monthly, :default => false 
      t.boolean  :complex, :default => false
      t.integer  :day, :default => 6 #if it is weekly, this stores the day of the week, and if this is monthly, day of the month
      t.integer  :day2, :default => 15  #if it is semi-monthly, this stores the second day of the month. (not used otherwise)
      #=========================

      t.timestamps
    end
  end

  def self.down
    drop_table :departments
  end
end

