class NoticesController < ApplicationController

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
    # TODO add department wide column on notices -Hugh
    # if params[:department_wide_locations] && current_user.is_admin_of?(current_department)
    #   notice.user_sources << current_department
    # end
		if params[:for_location_groups] 
      params[:for_location_groups].each do |loc_group|
				@loc_group = LocGroup.find_by_id(loc_group)
				if current_user.is_admin_of?(@loc_group) || notice.class.name == "Sticky"
          notice.loc_groups << @loc_group
      	end
			end

    end
    if params[:for_locations]
      params[:for_locations].each do |loc|
        notice.locations << loc
      end
    end
  end
end
