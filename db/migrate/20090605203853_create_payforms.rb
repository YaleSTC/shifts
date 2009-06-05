class CreatePayforms < ActiveRecord::Migration
  def self.up
    create_table :payforms do |t|
      t.datetime :date
      t.timestamps
    end
  end

  def self.down
    drop_table :payforms
  end
end

