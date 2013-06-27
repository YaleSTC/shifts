class AddLocationsNoticesLocGroupsNotices < ActiveRecord::Migration
  def self.up
    create_table :locations_notices, :id => false do |t|
      t.references :location
      t.references :notice
    end

    create_table :loc_groups_notices, :id => false do |t|
      t.references :loc_group
      t.references :notice
    end
  end

  def self.down
    drop_table :locations_notices
    drop_table :loc_groups_notices
  end
end
