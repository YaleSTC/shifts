module NoticesHelper

  def department_check(dept)
    @notice.departments.include?(dept)
  end

  def loc_group_check(loc_group)
    @notice.loc_groups.each do |lg|
      return true if lg == loc_group
    end
    false
  end

  def location_check(location)
    @notice.locations.each do |loc|
      return true if loc == location
    end
    current_user.current_shift.location == location if current_user.current_shift
    false
  end

  def type_check(sticky)
    if sticky
      @notice.is_sticky
    else
      !@notice.is_sticky
    end
  end
end

