module NoticesHelper
  def loc_group_checked_notice?(loc_group, notice)
    notice.loc_groups.each do |lg|
      return true if lg == loc_group
    end
    false
  end

  def location_checked_notice?(location, notice)
		return @current_shift_location == location if @current_shift_location
    notice.display_locations.each do |loc|
      return true if loc == location
    end
		false
  end

  def end_time_check(indefinite)
    if indefinite
      return true unless @announcement.created_at
    else
      return true if @announcement.created_at
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
