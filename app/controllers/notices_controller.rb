class NoticesController < ApplicationController

  def index
    @notices = Notice.active
  end

  def archive
    require_department_admin
    @notices = Notice.inactive
  end

  def destroy
    @notice = Notice.find_by_id(params[:id])
    unless @notice.type == "Sticky" || current_user.is_admin_of?(current_department)
      flash[:error] = "You are not authorized to remove this #{@notice.type.downcase}"
      redirect_to :back and return
    end
    unless @notice.is_current?
      flash[:error] = "This #{@notice.type.downcase} was already removed on #{@notice.end_time}"
      redirect_to :back and return
    end

    if @notice.remove(current_user) && @notice.save
      flash[:notice] = "#{@notice.type} successfully removed"
      redirect_to :back
    else
      flash[:error] = "Error removing #{@notice.type.downcase}"
      redirect_to :back
    end
  end

  def update_message_center
    respond_to do |format|
      format.js
    end
  end

  protected
  def set_sources(notice)
		if notice.type != "Announcement"
		  if params[:for_users]
		    params[:for_users].split(",").each do |l|
		      if l == l.split("||").first #This is for if javascript is disabled
		        l = l.strip
		        user_source = User.search(l) || Role.find_by_name(l)
		        find_dept = Department.find_by_name(l)
		        user_source = find_dept if find_dept && current_user.is_admin_of?(find_dept)
		        notice.user_sources << user_source if user_source
		      else
		        l = l.split("||")
		        notice.user_sources << l[0].constantize.find(l[1]) if l.length == 2 #javascript or not javascript
		      end
		    end
		  end
		end
    if params[:department_wide_locations] && current_user.is_admin_of?(current_department)
      notice.departments << current_department
			current_department.loc_groups.do |loc_group|
				notice.loc_group << loc_group
				loc_group.locations.each do |loc|
					notice.locations << loc
				end
			end
    end
		if params[:for_location_groups]
      params[:for_location_groups].each do |loc_group|
        notice.loc_groups << loc_group
      end
    end
    if params[:for_locations]
      params[:for_locations].each do |loc|
        notice.locations << Location.find_by_id(loc)
      end
    end
  end
end

