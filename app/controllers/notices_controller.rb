class NoticesController < ApplicationController

  def index
    @notices = Notice.active_notices
  end

  def archive
    require_department_admin
    @notices = Notice.inactive
  end

  def destroy
    @notice = Notice.find_by_id(params[:id])
    unless @notice.class.name == "Sticky" || current_user.is_admin_of?(current_department) || current_user == @notice.author
      flash[:error] = "You are not authorized to remove this #{@notice.type.downcase}"
      redirect_to :back and return
    end
    unless @notice.active? || @notice.start > Time.now
      flash[:error] = "This #{@notice.type.downcase} was already removed on #{@notice.end}"
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
    
		if params[:for_users] && notice.type == "Sticky"
			params[:for_users].split(",").each do |l|
		  	if l == l.split("||").first #This is for if javascript is disabled
		    	l = l.strip
		      user_source = User.search(l) || Role.find_by_name(l)
		      notice.user_sources << user_source if user_source
				else
		      l = l.split("||")
		      notice.user_sources << l[0].constantize.find(l[1]) if l.length == 2 #javascript or not javascript
		    end
		  end
		end
    if params[:department_wide_locations] && current_user.is_admin_of?(current_department)
      notice.user_sources << current_department
    end
		if params[:for_location_groups] 
      params[:for_location_groups].each do |loc_group|
				@loc_group = LocGroup.find_by_id(loc_group)
<<<<<<< HEAD
				if current_user.is_admin_of?(@loc_group) || notice.class.name == "Sticky"
        	notice.loc_groups << @loc_group	
					notice.locations << @loc_group.locations
=======
				if current_user.is_admin_of?(@loc_group)
        	notice.location_sources << @loc_group	
					notice.location_sources << @loc_group.locations
>>>>>>> debe88c4b878798a6644ea1273545f961a7af05e
      	end
			end

    end
    if params[:for_locations]
      params[:for_locations].each do |loc|
        notice.location_sources << Location.find_by_id(loc)
      end
    end
  end
end

