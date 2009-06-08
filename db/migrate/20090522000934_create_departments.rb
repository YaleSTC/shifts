class CreateDepartments < ActiveRecord::Migration
  def self.up
    create_table :departments do |t|
      t.string :name
      t.references :permission

      #Payform Configuration
      #=========================
      t.boolean  :monthly, :default => false #defaults to WEEKLY
      t.boolean  :complex, :default => true #where false = bi-weekly or semi-monthly, and true = weekly or monthly
      t.integer  :day #if it is weekly, this stores the day of the week, and if this is monthly, day of the month
      t.integer  :day2 #if it is semi-monthly, this stores the second day of the month. (not used otherwise)
      #=========================

      t.timestamps
    end
  end

  def self.down
    drop_table :departments
  end
end

