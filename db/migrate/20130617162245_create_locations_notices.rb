class CreateLocationsNotices < ActiveRecord::Migration
  def self.up
    create_table :locations_notices do |t|
      t.references :notice
      t.references :location

      t.timestamps
    end
  end

  def self.down
    drop_table :locations_notices
  end
end
