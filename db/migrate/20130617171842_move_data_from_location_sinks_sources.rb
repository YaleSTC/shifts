class MoveDataFromLocationSinksSources < ActiveRecord::Migration
  def self.up
    LocationSinksLocationSource.all.each do |lsls|
      if lsls.location_sink_type == "Notice"
        if !(notice = Notice.find_by_id(lsls.location_sink_id))
          next
        end

        if lsls.location_source_type == "Location"
          n = LocationsNotice.new
          n.location_id = lsls.location_source_id
        elsif lsls.location_source_type == "LocGroup"
          n = LocGroupsNotice.new
          n.loc_group_id = lsls.location_source_id
        else
          next
        end

        n.notice_id = lsls.location_sink_id
        n.save!
      end
    end
  end

  def self.down
  end
end
