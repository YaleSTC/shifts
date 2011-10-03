class PublicViewController < ApplicationController

  skip_before_filter :login_check
  skip_before_filter CASClient::Frameworks::Rails::Filter
  helper :shifts
  helper :loc_groups
  
  def index
    #@date = params[:date].to_date
    @loc_groups = LocGroup.find(:all, :conditions => ["#{:public} = ?", true])
    @view_days = (Date.today..Date.today+7)
  end

  def for_location
    @location = Location.find(params[:id])
    @view_days = (Date.today..Date.today+7)

    @current_shifts = Shift.in_location(@location).signed_in(@location.department).delete_if{|shift| shift.stale_shifts_with_unsent_emails}
    @upcoming_shifts = @location.shifts_between(Time.now, Time.now + 12.hours).delete_if{|shift| shift.submitted?}.sort_by{|shift| [shift.start]}.drop(@current_shifts.size).first(5)
  end
end

