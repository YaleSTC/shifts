class StatsController < ApplicationController
 
  def index
    return unless user_is_admin_of(current_department)
    @start_date = params[:stat] ? Date.civil(params[:stat][:"start_date(1i)"].to_i,params[:stat][:"start_date(2i)"].to_i,params[:stat][:"start_date(3i)"].to_i) : 1.week.ago.to_date
    @end_date = params[:stat] ? Date.civil(params[:stat][:"end_date(1i)"].to_i,params[:stat][:"end_date(2i)"].to_i,params[:stat][:"end_date(3i)"].to_i) : Date.today.to_date
    @user_stats = {}
    @location_stats = {}
    
    users = current_department.active_users.sort_by(&:last_name)
    locations = current_department.locations.active.sort_by(&:short_name)

    users.each do |u|
      user_stats = {}
      
      shifts = u.shifts.on_days(@start_date, @end_date).active

      user_stats[:u] = u
      user_stats[:name] = u.name
      user_stats[:num_shifts] = shifts.size
      user_stats[:num_late] = shifts.select{|s| s.late == true}.size
      user_stats[:num_missed] = shifts.select{|s| s.missed == true}.size
      user_stats[:num_left_early] = shifts.select{|s| s.left_early == true}.size
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
    @start_date = params[:stat] ? Date.civil(params[:stat][:"start_date(1i)"].to_i,params[:stat][:"start_date(2i)"].to_i,params[:stat][:"start_date(3i)"].to_i) : 1.week.ago.to_date
    @end_date = params[:stat] ? Date.civil(params[:stat][:"end_date(1i)"].to_i,params[:stat][:"end_date(2i)"].to_i,params[:stat][:"end_date(3i)"].to_i) : Date.today.to_date
    @shifts = @user.shifts.on_days(@start_date, @end_date).active
    @stats_hash = @user.detailed_stats(@start_date, @end_date)
  rescue
    redirect_to :action => 'for_user', :id => @user.id
    flash[:notice] = "Please enter a valid date range."
  end
  
  def for_location
    @location = Location.find(params[:id])
    return unless user_is_admin_of(@location.loc_group)
    @start_date = params[:stat] ? Date.civil(params[:stat][:"start_date(1i)"].to_i,params[:stat][:"start_date(2i)"].to_i,params[:stat][:"start_date(3i)"].to_i) : 1.week.ago.to_date
    @end_date = params[:stat] ? Date.civil(params[:stat][:"end_date(1i)"].to_i,params[:stat][:"end_date(2i)"].to_i,params[:stat][:"end_date(3i)"].to_i) : Date.today.to_date
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
  
end



  # def index
  #     return unless user_is_admin_of(current_department)
  #     @start_date = params[:start_date] ? Date.parse(params[:start_date]) : 1.week.ago.to_date
  #     @end_date = params[:end_date] ? Date.parse(params[:end_date]) : 1.day.ago.to_date
  # 
  #     @stats = {}
  # 
  #     users = current_department.active_users.sort_by(&:last_name)
  # 
  #     users.each do |u|
  #       user_stats = {}
  #       
  #       shifts = u.shifts.on_days(@start_date, @end_date).active
  # 
  #       user_stats[:name] = u.name
  #       
  #       user_stats[:num_shifts] = shifts.size
  #       user_stats[:num_late] = shifts.select{|s| s.late?}.size
  #       user_stats[:num_missed] = shifts.select{|s| s.missed?}.size
  #       user_stats[:num_left_early] = shifts.select{|s| s.left_early?}.size 
  #       #user_stats[:scheduled_duration] = shifts.map{|s| s.duration(actual = false)}.sum
  #       #user_stats[:actual_duration] = shifts.map{|s| s.duration(actual = true)}.sum
  #               
  #       @stats[u.id] = user_stats
  #     end
  # end
