class SetNotificationsGlobal < ActiveRecord::Migration
  def self.up
    # This migration technically works, but there are no department wide
    # announcements to migrate
    b = Location.active.sort_by(&:name).uniq

    Notice.active.each do |notice|
      a = notice.locations.active.sort_by(&:name).uniq
      if a == b
        notice.global = true
      else
        notice.global = false
      end
      notice.save
    end
  end

  def self.down
    Notice.active.each do |notice|
      notice.global = nil
      notice.save
    end
  end
end
