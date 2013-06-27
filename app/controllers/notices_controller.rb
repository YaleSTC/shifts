class NoticesController < ApplicationController

  def archive
    require_department_admin
    @notices = Notice.inactive
  end

  def destroy
    @notice = Notice.where(:id == params[:id]).first
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
    
    if params[:department_wide_locations] && current_user.is_admin_of?(current_department)
      notice.user_sources << current_department
    end
		if params[:for_location_groups] 
      params[:for_location_groups].each do |loc_group|
				@loc_group = LocGroup.where(:id == loc_group)
				if current_user.is_admin_of?(@loc_group) || notice.class.name == "Sticky"
        	notice.location_sources << @loc_group	
					notice.location_sources << @loc_group.locations
      	end
			end

    end
    if params[:for_locations]
      params[:for_locations].each do |loc|
        notice.location_sources << Location.where(:id == loc)
      end
    end
  end
end
