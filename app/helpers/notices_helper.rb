module NoticesHelper

  def department_check(dept, notice)
   notice.departments.each do |d|
      return true if d == dept
    end
    false
  end

  def loc_group_check(loc_group, notice)
    notice.loc_groups.each do |lg|
      return true if lg == loc_group
    end
    false
  end

  def location_check(location, notice)
		return @current_shift_location == location if @current_shift_location
    notice.location_sources.each do |loc|
      return true if loc == location
    end
  end


  def end_time_check(indefinite)
    if indefinite
      return true unless @announcement.end
    else
      return true if @announcement.end
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

