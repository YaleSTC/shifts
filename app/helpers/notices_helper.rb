module NoticesHelper

  def locations_check(location)
    if current_user.current_shift
      !@notice.departments.each{|d| d.locations.include?(location)}.empty? or
      current_user.current_shift.location == location or
      @notice.locations.include?(location) or
      !@notice.loc_groups.each{lg.locations.include?(location)}.empty?
    else
      !@notice.departments.each{|d| d.locations.include?(location)}.empty? or
      @notice.locations.include?(location) or
      !@notice.loc_groups.each{lg.locations.include?(location)}.empty?
    end
  end

  def loc_group_check(loc_group)
    unless @notice.departments.empty?
      @notice.loc_groups.include?(loc_group)
    else
      !@notice.departments.each{|d| d.loc_groups.include?(loc_group)}.empty?
    end
  end

  def dept_check
    @notice.departments.include?(current_department)
  end

  def update_checkboxes
    @notice = Notice.new(params[:notice])
    render :new do |page|
      page.replace_html('advanced_options_div', :partial => "advanced_options")
    end
  end

end

