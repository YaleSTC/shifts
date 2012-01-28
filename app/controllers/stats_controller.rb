class StatsController < ApplicationController
 
  def index
    # return unless user_is_admin_of(current_department)
    @start_date = interpret_start
    @end_date = interpret_end
    @user_stats = {}
    @location_stats = {}
    
    users = current_user.to_a
    locations = []
    if current_user.loc_groups_to_admin(current_department) != []
      loc_groups = current_user.loc_groups_to_admin(current_department)
      loc_groups.each do |lg|
        lg.locations.each do |l|
          locations << l
        end
      end
    end
    if current_user.is_admin_of?(current_department)
      users = current_department.active_users.sort_by(&:last_name)
      locations = current_department.locations.active.sort_by(&:short_name)
    end
    
    users.each do |u|
      user_stats = {}
      if params[:calendar]
        shifts = u.shifts.on_days(@start_date, @end_date).in_calendars(params[:calendar].split(","))
      else
        shifts = u.shifts.on_days(@start_date, @end_date).active
      end
      user_stats[:u] = u
      user_stats[:name] = u.name
      user_stats[:num_shifts] = shifts.size
      user_stats[:num_late] = shifts.select{|s| s.late == true}.size
      user_stats[:num_missed] = shifts.select{|s| s.missed == true}.size
      user_stats[:num_left_early] = shifts.select{|s| s.left_early == true}.size
      user_stats[:hours_scheduled] = shifts.select{|s| s.location_id != 3}.collect(&:duration).sum
      user_stats[:io_hours_scheduled] = shifts.select{|s| (s.location_id == 3 || s.location_id == 36)}.collect(&:duration).sum
      valid_report_stats = shifts.select{|s| s.parsed == true}.collect(&:updates_hour).delete_if{|r| r == nil}
      if valid_report_stats.size == 0
        user_stats[:updates] = nil
      else
        user_stats[:updates] = valid_report_stats.sum/valid_report_stats.size
      end
      @user_stats[u.id] = user_stats
    end

    locations.each do |l|
      location_stats = {}
      
      shifts = l.shifts.on_days(@start_date, @end_date).active

      location_stats[:l] = l
      location_stats[:name] = l.name
      location_stats[:num_shifts] = shifts.size
      location_stats[:num_late] = shifts.select{|s| s.late == true}.size
      location_stats[:num_missed] = shifts.select{|s| s.missed == true}.size
      location_stats[:num_left_early] = shifts.select{|s| s.left_early == true}.size
      valid_report_stats = shifts.select{|s| s.parsed == true}.collect(&:updates_hour).delete_if{|r| r == nil}
      if valid_report_stats.size == 0
        location_stats[:updates] = nil
      else
        location_stats[:updates] = valid_report_stats.sum/valid_report_stats.size
      end
      @location_stats[l.id] = location_stats
    end
  rescue
    redirect_to stats_path
    flash[:notice] = "Please enter a valid date range."
  end

  def for_user
    @user = User.find(params[:id])
    return unless user_is_owner_or_admin_of(@user, current_department)
    @start_date = interpret_start
    @end_date = interpret_end
    @shifts = @user.shifts.on_days(@start_date, @end_date).active
    @stats_hash = @user.detailed_stats(@start_date, @end_date)
  rescue
    redirect_to :action => 'for_user', :id => @user.id
    flash[:notice] = "Please enter a valid date range."
  end
  
  def for_location
    @location = Location.find(params[:id])
    return unless user_is_admin_of(@location.loc_group)
    @start_date = interpret_start
    @end_date = interpret_end
    @shifts = @location.shifts.on_days(@start_date, @end_date).active
    @stats_hash = @location.detailed_stats(@start_date, @end_date)
  rescue
    redirect_to :action => 'for_location', :id => @location.id
    flash[:notice] = "Please enter a valid date range."  
  end
  
  def show
    begin
      @shift = Shift.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        # format.html #freak out
        format.js do
          render :update do |page|
            ajax_alert(page, "<strong>Error (404):</strong> shift ##{params[:id]} cannot be found. Please refresh the current page.")
            page.hide "tooltip"
          end
        end
      end
    else
      return unless require_department_membership(@shift.department)
    end
  end
  
  private
  
  def interpret_start
    if params[:stat]
      return Date.civil(params[:stat][:"start_date(1i)"].to_i,params[:stat][:"start_date(2i)"].to_i,params[:stat][:"start_date(3i)"].to_i)
    elsif params[:start_date]
      return params[:start_date].to_date
    else
      return 1.week.ago.to_date
    end
  end
  
  def interpret_end
    if params[:stat]
      return Date.civil(params[:stat][:"end_date(1i)"].to_i,params[:stat][:"end_date(2i)"].to_i,params[:stat][:"end_date(3i)"].to_i)
    elsif params[:end_date]
      return params[:end_date].to_date
    else
      return Date.today.to_date
    end
  end
  
end