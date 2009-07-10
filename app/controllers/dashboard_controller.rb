class DashboardController < ApplicationController
  helper ShiftsHelper
  def index
    @upcoming_shifts = current_user.shifts.select{|shift| !(shift.submitted?) and shift.scheduled? and shift.end > Time.now and @department.locations.include?(shift.location)}.sort_by(&:start)[0..3]
    @most_recent_payform= current_user.payforms.sort_by(&:date).last
  end

end
