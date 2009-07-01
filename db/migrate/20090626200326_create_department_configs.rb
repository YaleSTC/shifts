class CreateDepartmentConfigs < ActiveRecord::Migration
  def self.up
    create_table :department_configs do |t|
      t.integer :department_id
      t.integer :schedule_start
      t.integer :schedule_end
      t.integer :time_increment
      t.integer :grace_period
      t.boolean :edit_report

      t.timestamps
    end
  end

  def self.down
    drop_table :department_configs
  end
end

