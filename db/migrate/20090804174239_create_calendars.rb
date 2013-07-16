class CreateCalendars < ActiveRecord::Migration
  def self.up
    create_table :calendars do |t|
      t.string :name
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :active
      t.references :department
      t.boolean :default, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :calendars
  end
end
