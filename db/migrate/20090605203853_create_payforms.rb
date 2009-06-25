class CreatePayforms < ActiveRecord::Migration
  def self.up
    create_table :payforms do |t|
      t.date :date

      #Payform Configuration
      #=========================
      t.boolean  :monthly, :default => false
      t.boolean  :end_of_month, :default => false
      t.integer  :day, :default => 6 #if it is weekly, this stores the day of the week, and if this is monthly, day of the month
      #=========================

      t.datetime :submitted
      t.datetime :approved
      t.datetime :printed
      
      t.references :approved_by

      t.references :department
      t.references :user
      t.references :payform_set

      t.timestamps
    end
  end

  def self.down
    drop_table :payforms
  end
end

