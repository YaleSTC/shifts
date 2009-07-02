module NoticesHelper

  def locations_check(location)
    @notice.departments.locations.include?(location) or current_user.current_shift.location == location or @notice.locations.include?(location) or loc_group.locations.include?(location)
  end

  def loc_group_check(loc_group)
    if @notice.departments.empty?
      @notice.loc_groups.include?(loc_group)
    else
      @notice.departments.loc_groups.include?(loc_group)
    end
  end

  def dept_check
    @notice.departments.include?(current_department)
  end

end

