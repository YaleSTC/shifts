class AddPublicToCalendar < ActiveRecord::Migration
  def self.up
    add_column :calendars, :public, :boolean
  end

  def self.down
    remove_column :calendars, :public
  end
end
