class CreateAnnouncements < ActiveRecord::Migration
  def self.up
    create_table :announcements do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :announcements
  end
end
