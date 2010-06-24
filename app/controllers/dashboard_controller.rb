class DashboardController < ApplicationController
  helper :shifts
  helper :data_entries
  helper :punch_clocks

  def index
    @signed_in_shifts = Shift.signed_in(current_department).sort_by(&:start).group_by(&:loc_group)
    @upcoming_shifts = Shift.find(:all, :conditions => ["#{:user_id} = ? and #{:end} > ? and #{:department_id} = ? and #{:scheduled} = ? and #{:active} = ?", current_user, Time.now.utc, current_department.id, true, true], :order => :start, :limit => 5)

    @subs_you_requested = SubRequest.find(:all, :conditions => ["end > ? AND user_id = ?", Time.now.utc, current_user.id]).sort_by(&:start)
    @subs_you_can_take = current_user.available_sub_requests(@department)

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
