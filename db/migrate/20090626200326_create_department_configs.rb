class CreateDepartmentConfigs < ActiveRecord::Migration
  def self.up
    create_table :department_configs do |t|
      t.integer :department_id
      t.integer :schedule_start
      t.integer :schedule_end
      t.integer :time_increment
      t.integer :grace_period
      t.boolean :edit_report
      t.boolean :auto_remind, :default => true
      t.boolean :auto_warn, :default => true
      t.string  :mailer_address

      #Payform Period Config
      #=========================
      t.boolean  :monthly, :default => false
      t.boolean  :end_of_month, :default => false
      t.integer  :day, :default => 6 #if it is weekly, this stores the day of the week that the period ENDS on, and if this is monthly, day of the month
      #=========================


      t.timestamps
    end
  end

  def self.down
    drop_table :department_configs
  end
end

