class CreateShiftsTasks < ActiveRecord::Migration
  def self.up
    create_table :shifts_tasks, id: false do |t|
      t.references :task
      t.references :shift

      t.timestamps
    end
  end

  def self.down
    drop_table :shifts_tasks
  end
end