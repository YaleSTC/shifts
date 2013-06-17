class CreateLocGroupsNotices < ActiveRecord::Migration
  def self.up
    create_table :loc_groups_notices do |t|
      t.references :notice
      t.references :loc_group

      t.timestamps
    end
  end

  def self.down
    drop_table :loc_groups_notices
  end
end
