class CreatePayforms < ActiveRecord::Migration
  def self.up
    create_table :payforms do |t|
      t.datetime :date

      #PAYFORM PERIOD INFO
      t.boolean  :monthly, :default => false #defaults to WEEKLY
      t.boolean  :type, :default => true #where false = bi-weekly or semi-monthly, and true = weekly or monthly
      t.integer  :day #if it is weekly, this stores the day of the week, and if this is monthly, day of the month
      t.datetime :printed #date and time printed

      t.references :department
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :payforms
  end
end

