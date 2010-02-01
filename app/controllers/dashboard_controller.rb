class DashboardController < ApplicationController
  helper :shifts
  helper :data_entries
  helper :punch_clocks

  def index
    @active_shifts = Shift.find(:all, :conditions => {:signed_in => true, :department_id => current_department.id}, :order => :start)
    @upcoming_shifts = Shift.find(:all, :conditions => ["#{:user_id.to_sql_column} = ? and #{:end.to_sql_column} > ? and #{:department_id.to_sql_column} = ? and #{:scheduled.to_sql_column} = ? and #{:active.to_sql_column} = ?", current_user.to_sql, Time.now.utc, current_department.id.to_sql, true, true], :order => :start, :limit => 5)
    @subs_you_requested = SubRequest.find(:all, :conditions => ["#{:end.to_sql_column} > ? AND #{:user_id.to_sql_column} = ?", Time.now.to_sql, current_user.id.to_sql]).sort_by(&:start)
    @subs_you_can_take = current_user.available_sub_requests([@department]).select{|sub| sub.end > Time.now}.sort_by(&:start)

    @most_recent_payform= current_user.payforms.sort_by(&:date).last
    @watched_objects = DataObject.find(current_user.user_config.watched_data_objects.split(', ')).group_by(&:data_type)
    @dept_start_hour = current_department.department_config.schedule_start / 60
    @dept_end_hour = current_department.department_config.schedule_end / 60
    @hours_per_day = (@dept_end_hour - @dept_start_hour)
    @dept_start_minute = @dept_start_hour * 60
    @dept_end_minute = @dept_end_hour * 60
    @loc_groups = current_user.user_config.view_loc_groups
    @display_unscheduled_shifts = @department.department_config.unscheduled_shifts
    @time_increment = current_department.department_config.time_increment
    @blocks_per_hour = 60/@time_increment.to_f
  end

end

