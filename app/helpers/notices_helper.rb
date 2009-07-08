module NoticesHelper

  def locations_check(location)
    if current_user.current_shift
      current_user.current_shift.location == location ||
      @notice.locations.include?(location)
    else
      @notice.locations.include?(location)
    end
  end

  def loc_group_check(loc_group)
    @notice.loc_groups.include?(loc_group)
  end

  def dept_check
    @notice.departments.include?(current_department)
  end

#  def update_checkboxes
#    raise params.to_yaml
#    @notice = Notice.new(params[:notice])
#    render :update do |page|
#      page.replace_html('advanced_options_div', :partial => "advanced_options")
#    end
#  end

end

