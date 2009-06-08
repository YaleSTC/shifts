class CreatePayforms < ActiveRecord::Migration
  def self.up
    create_table :payforms do |t|
      t.datetime :date
      t.boolean  :monthly, :default => false #defaults to WEEKLY
      t.boolean  :type, :default => true #where false = bi-weekly or semi-monthly, and true = weekly or monthly
      t.datetime :printed #date and time printed
      t.timestamps
    end
  end

  def self.down
    drop_table :payforms
  end
end

