class NoticesController < ApplicationController

  def index
    @notices = Notice.active
  end

  def archive
    require_department_admin
    @notices = Notice.inactive
  end

  def show
    @notice = Notice.find(params[:id])
  end

  def new
    @notice_type = params[:type]
    @current_shift_location = current_user.current_shift.location if current_user.current_shift
    @notice = Notice.new
    layout_check
  end

  def edit
    require_department_admin
    @current_shift_location = current_user.current_shift.location if current_user.current_shift
    @notice = Notice.find(params[:id])
    layout_check
  end

  def create
    @report = current_user.current_shift.report if current_user.current_shift
    @notice = Notice.new(params[:notice])
    @notice.author = current_user
    @notice.department = current_department
    @notice.sticky = true if params[:type] == "sticky"
    @notice.announcement = true if params[:type] == "announcement" && current_user.is_admin_of?(current_department)
    if params[:type] == "link"
      @notice.useful_link = true if params[:type] == "link"
      @notice.content = params[:link_label] + "|$|" + "http://" + params[:url]
      @notice.content.gsub!("http://http://", "http://")
      @notice.start_time = Time.now
      @notice.end_time = nil
      @notice.indefinite = true
    else
      @notice.start_time = Time.now if params[:start_time_choice] == 'now' || @notice.sticky
      @notice.end_time = nil if params[:end_time_choice] == "indefinite" || @notice.sticky
      @notice.indefinite = true if params[:end_time_choice] == "indefinite" || @notice.sticky
    end
    begin
      Notice.transaction do
        @notice.save(false) #polymorphic associations require a saved database record
        set_sources #setting polymorphic user and location sources
        @notice.save! #saving again to run validations
      end
    rescue Exception
      respond_to do |format|
        format.html { render :action => "new" }
        format.js  #create.js.rjs
      end
    else
      respond_to do |format|
        format.html {
        flash[:notice] = 'Notice was successfully created.'
        redirect_to notices_path
        }
        format.js  #create.js.rjs
      end
    end
  end

  def update
    @notice = Notice.find_by_id(params[:id]) || Notice.new
    @notice.update_attributes(params[:notice])
    @notice.is_sticky = true if params[:type] == "sticky"
    @notice.is_sticky = false if params[:type] == "announcement" && current_user.is_admin_of?(current_department)
    @notice.author = current_user
    @notice.department = current_department
    @notice.start_time = Time.now if @notice.is_sticky
    @notice.end_time = nil if params[:end_time_choice] == "indefinite" || @notice.is_sticky
    @notice.indefinite = true if params[:end_time_choice] == "indefinite" || @notice.is_sticky
#    raise params.to_yaml
    begin
      Notice.transaction do
        @notice.save(false)
        set_sources
        @notice.save!
      end
    rescue Exception
        respond_to do |format|
          format.html { render :action => "edit" }
          format.js  #update.js.rjs
        end
      else
        respond_to do |format|
        format.html {
          flash[:notice] = 'Notice was successfully saved.'
          redirect_to :action => "index"
        }
        format.js  #update.js.rjs
      end
    end
  end

  def destroy
    @notice = Notice.find(params[:id])
    unless @notice.is_sticky || current_user.is_admin_of?(current_department)
      redirect_with_flash("You are not authorized to remove this notice", :back) and return
    end
    unless @notice.is_current?
      redirect_with_flash("This notice was already removed on #{@notice.end_time}", :back) and return
    end
    if @notice.remove(current_user) && @notice.save
      redirect_with_flash("Notice successfully removed", :back)
    else
      redirect_with_flash("Error removing notice", :back)
    end
  end

  def update_message_center
    respond_to do |format|
      format.js
    end
  end

  protected

  def set_sources
    if params[:for_users]
      params[:for_users].split(",").each do |l|
        if l == l.split("||").first #This is for if javascript is disabled
          l = l.strip
          user_source = User.search_by_name_and_login(l) || Role.find_by_name(l)
          find_dept = Department.find_by_name(l)
          user_source = find_dept if find_dept && current_user.is_admin_of?(find_dept)
          @notice.user_sources << user_source if user_source
        else
          l = l.split("||")
          @notice.user_sources << l[0].constantize.find(l[1]) if l.length == 2 #javascript or not javascript
        end
      end
    end
    if params[:department_wide_locations] && current_user.is_admin_of?(current_department)
      @notice.location_sources << current_department
      @notice.departments << current_department
      @notice.loc_groups << current_department.loc_groups
      @notice.locations << current_department.locations
    elsif params[:for_location_groups]
      params[:for_location_groups].each do |loc_group|
        lg = LocGroup.find(loc_group)
        @notice.loc_groups << lg
        @notice.locations << lg.locations
      end
    end
    if params[:for_locations]
      params[:for_locations].each do |loc|
        @notice.locations << Location.find_by_id(loc)
      end
    end
  end
end

