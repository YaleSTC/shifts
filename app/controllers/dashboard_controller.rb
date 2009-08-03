class DashboardController < ApplicationController
  helper :shifts

  def index
    @upcoming_shifts = current_user.shifts.select{|shift| !(shift.submitted?) and shift.scheduled? and shift.end > Time.now and @department.locations.include?(shift.location)}.sort_by(&:start)[0..3]
    @most_recent_payform= current_user.payforms.sort_by(&:date).last
    @dept_start_hour = current_department.department_config.schedule_start / 60
    @dept_end_hour = current_department.department_config.schedule_end / 60
    @hours_per_day = (@dept_end_hour - @dept_start_hour)
    @dept_start_minute = @dept_start_hour * 60
    @dept_end_minute = @dept_end_hour * 60
    @loc_groups = current_user.user_config.view_loc_groups.split(', ').map{|lg|LocGroup.find(lg)}.select{|l| !l.locations.empty?}
    @display_unscheduled_shifts = @department.department_config.unscheduled_shifts
    @time_increment = current_department.department_config.time_increment
    @blocks_per_hour = 60/@time_increment.to_f
  end

end
