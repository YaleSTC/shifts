class MoveDataFromLocationSinksSources < ActiveRecord::Migration
  def self.up
    LocationSinksLocationSource.all.each do |lsls|
      if lsls.location_sink_type == "Notice"
        if !(notice = Notice.where(:id => lsls.location_sink_id).first).
          next
        end

        if lsls.location_source_type == "Location"
          notice.locations << Location.find(lsls.location_source_id)
        elsif lsls.location_source_type == "LocGroup"
          notice.loc_groups << LocGroup.find(lsls.location_source_id)
        else
          next
        end
      end
    end
  end

  def self.down
    # WHY WOULD YOU WANT TO DO THAT
    # But actually going down would break everything, because sinks/sources
    # relies on an outdated gem called has_many_polymorphs.
  end
end
