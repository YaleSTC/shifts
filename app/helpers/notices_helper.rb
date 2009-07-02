module NoticesHelper

  def locations_check(location)
    @notice.departments.each{|d| d.locations.include?(location)} or
    current_user.current_shift.location == location or
    @notice.locations.include?(location) or
    loc_group.locations.include?(location)
  end

  def loc_group_check(loc_group)
    unless @notice.departments.empty?
      @notice.loc_groups.include?(loc_group)
    else
      @notice.departments.each{|d| d.loc_groups.include?(loc_group)}
    end
  end

  def dept_check
    @notice.departments.include?(current_department)
  end

end

