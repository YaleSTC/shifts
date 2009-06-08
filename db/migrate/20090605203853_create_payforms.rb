class CreatePayforms < ActiveRecord::Migration
  def self.up
    create_table :payforms do |t|
      t.date :date

      #PAYFORM PERIOD INFO
      t.boolean  :monthly, :default => false #defaults to WEEKLY
      t.boolean  :complex, :default => true #where false = bi-weekly or semi-monthly, and true = weekly or monthly
      t.integer  :day #if it is weekly, this stores the day of the week, and if this is monthly, day of the month

      #payform status
      t.datetime :submitted
      t.datetime :approved
      t.datetime :printed

      t.references :department
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :payforms
  end
end

