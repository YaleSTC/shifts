module NoticesHelper
  def loc_group_checked_notice?(loc_group, notice)
    notice.loc_groups.each do |lg|
      return true if lg == loc_group
    end
    loc_group.locations.active.each do |loc|
      return false if !location_checked_notice?(loc, notice)
    end
    true
  end

  def location_checked_notice?(location, notice)
		return @current_shift_location == location if @current_shift_location
    notice.display_locations.each do |loc|
      return true if loc == location
    end
		false
  end

  # if the radio_button should be selected
  # returns the result for the indefinite radio_button if indifinite is true
  # returns the result for the End radio_button if indefinite is false
  def end_time_check(indefinite)
    if indefinite
      return @announcement.created_at && @announcement.indefinite
    else
      return @announcement.created_at && !@announcement.indefinite
    end
  end

  def start_time_check(now)
    if now
      !@announcement.is_upcoming?
    else
      @announcement.is_upcoming?
    end
  end
end
