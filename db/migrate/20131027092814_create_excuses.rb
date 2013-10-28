class CreateExcuses < ActiveRecord::Migration
  def self.up
    create_table :excuses do |t|
      t.text :excuse
      t.boolean :excused
      t.belongs_to :shift

      t.timestamps
    end
  end

  def self.down
    drop_table :excuses
  end
end
