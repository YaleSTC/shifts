class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.references :location
      t.string :name
      t.string :kind
      t.datetime :start
      t.datetime :end
      t.boolean :interval_completed, default: false
      t.time :time_of_day
      t.string :day_in_week
      t.boolean :active, default: true
      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end