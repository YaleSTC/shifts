class CreateDepartmentConfigs < ActiveRecord::Migration
  def self.up
    create_table :department_configs do |t|
      t.integer :department_id
      t.integer :schedule_start
      t.integer :schedule_end
      t.integer :time_increment
      t.integer :grace_period
      t.boolean :edit_report

      #Payform Period Config
      #=========================
      t.boolean  :monthly, :default => false
      t.boolean  :complex, :default => false
      t.boolean  :end_of_month, :default => false
      t.integer  :day, :default => 6 #if it is weekly, this stores the day of the week that the period ENDS on, and if this is monthly, day of the month
      t.integer  :day2, :default => 1  #if it is semi-monthly, this stores the second day of the month. (not used otherwise)
      #=========================


      t.timestamps
    end
  end

  def self.down
    drop_table :department_configs
  end
end

