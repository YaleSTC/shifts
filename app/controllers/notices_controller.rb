class NoticesController < ApplicationController

  def index
    @notices = Notice.all
  end

  def archive
    @notices = Notice.inactive
  end

  def show
    @notice = Notice.find(params[:id])
    render :action => "show", :layout => false
  end

  def new
    @notice = Notice.new
    render :action => "new", :layout => 'new_notice'
  end

  def edit
    @notice = Notice.find(params[:id])
    render :action => "edit", :layout => 'new_notice'
  end

  def create
    @notice = Notice.new(params[:notice])
    @notice.is_sticky = true unless current_user.is_admin_of?(current_department)
    @notice.author = current_user
    @notice.department = @department
    @notice.start_time = Time.now if @notice.is_sticky
    @notice.end_time = nil if params[:indefinite] || @notice.is_sticky
    if @notice.save
      set_sources
      flash[:notice] = 'Notice was successfully created.'
      redirect_to @notice
    else
      render :action => "new", :layout => 'new_notice'
    end
  end

  def update
    @notice = Notice.find(params[:id])
    @notice.update_attributes(params[:notice])
    @notice.is_sticky = true unless current_user.is_admin_of?(current_department)
    @notice.author = current_user
    @notice.department = current_department
    @notice.start_time = Time.now if @notice.is_sticky
    @notice.end_time = nil if params[:indefinite] || @notice.is_sticky
    set_sources(true)
    if current_user.is_admin_of?(current_department) && @notice.save
      flash[:notice] = 'Notice was successfully updated.'
      redirect_to @notice
    else
      render :action => "edit"
    end
  end

  def destroy
    @notice = Notice.find(params[:id])
    unless @notice.is_sticky || current_user.is_admin_of?(@notice.department)
      redirect_with_flash("You are not authorized to remove this notice", :back) and return
    end
    unless @notice.is_current?
      redirect_with_flash("This notice was already removed on #{@notice.end_time}", :back) and return
    end
    if @notice.remove(current_user) && (@notice.save)
      redirect_with_flash("Notice successfully removed", :back)
    else
      redirect_with_flash "Error removing notice", :back
    end
  end

  def update_checkboxes
    raise params.to_yaml
    @notice = Notice.new(params[:notice])
    render :update do |page|
      page.replace_html('advanced_options_div', :partial => "advanced_options")
    end
  end

  protected

  def set_sources(update = false)
#    @notice.user_sources = [] if update
#    @notice.location_sources = [] if update
    if params[:for_users]
      params[:for_users].split(",").each do |l|
        l = l.split("||")
        @notice.user_sources << l[0].constantize.find(l[1]) if l.length == 2
      end
    end
    @notice.user_sources << current_department if params[:department_wide_viewers] && !@notice.is_sticky && current_user.is_admin_of?(current_department)
    if params[:department_wide_locations] && current_user.is_admin_of?(current_department)
      @notice.departments << current_department
      @notice.loc_groups << current_department.loc_groups
      @notice.locations << current_department.loc_groups.collect {|lg| lg.locations}
    elsif params[:for_location_groups]
      params[:for_location_groups].each do |loc_group|
        @notice.loc_groups << LocGroup.find_by_id(loc_group)
        @notice.locations << loc_group.collect{|lg| lg.locations}
      end
    end
    if params[:for_locations]
      params[:for_locations].each do |loc|
        @notice.locations << Location.find_by_id(loc)
      end
    end
  end
end

