class DashboardController < ApplicationController
  
  def index
    @shifts = Shift.all
    @current_shifts = Shift.all.select{|s| s.report and !s.submitted? and @department.locations.include?(s.location)}.sort_by(&:start)
    @period_start = params[:date].blank? ? Date.parse("last Sunday") : Date.parse(params[:date])
    @days_per_period = 7 #TODO: make this a setting for an admin
    @show_weekends = false
    @upcoming_shifts = current_user.shifts.select{|shift| !(shift.submitted?) and shift.scheduled? and shift.end > Time.now and @department.locations.include?(shift.location)}.sort_by(&:start)[0..3]
    @subs_you_can_take = current_user.available_sub_requests
  end
  
end

