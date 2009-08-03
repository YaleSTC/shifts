module NoticesHelper

  def department_check(dept)
    @notice.departments == dept
  end

  def loc_group_check(loc_group)
    @notice.loc_groups.each do |lg|
      return true if lg == loc_groups
    end
    false
  end

  def location_check(location)
    if current_user.current_shift
      current_user.current_shift.location == location
    else
      @notice.locations.each do |loc|
        return true if loc == location
      end
    end
    false
  end
end

