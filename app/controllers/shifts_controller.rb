class ShiftsController < ApplicationController
  def index
    @shifts = Shift.all
    @current_shifts = Shift.all.select{|s| s.report and !s.submitted? and @department.locations.include?(s.location)}.sort_by(&:start)
    @period_start = params[:date].blank? ? Date.parse("last Sunday") : Date.parse(params[:date])
    @days_per_period = 7 #TODO: make this a setting for an admin
    @show_weekends = false
    @upcoming_shifts = current_user.shifts.select{|shift| !(shift.submitted?) and shift.scheduled? and shift.end > Time.now and @department.locations.include?(shift.location)}.sort_by(&:start)[0..3]
    @announcements = current_user.notices
  end

  def show
    @shift = Shift.find(params[:id])
  end

  def show_active
    @current_shifts = Shift.all.select{|s| s.report and !s.submitted? and @department.locations.include?(s.location)}.sort_by(&:start)
  end

  def show_unscheduled
    @start_date = 1.week.ago
    @end_date = Date.current
    if request.post?
      @start_date = Time.local(params[:start][:year], params[:start][:month], params[:start][:day])
      @end_date = Time.local(params[:end][:year], params[:end][:month], params[:end][:day], 23, 59, 59)
    end
    @unscheduled_shifts_by_locgroup = Shift.all.select{|s| !s.scheduled? and @department.locations.include?(s.location) and (@start_date <= s.start and s.start <= @end_date)}.sort_by(&:start).group_by(&:loc_group)
  end

  def new
    params[:shift][:end] ||= params[:shift][:start] if params[:shift] and params[:shift][:start]
    @shift = Shift.new(params[:shift])
    (render :partial => 'shifts/tooltips/new', :layout => 'none') if params[:tooltip]
  end

  def unscheduled
    @shift = Shift.new
  end

  def power_sign_up
    @shift = Shift.new
  end

  def create
    @shift = Shift.new(params[:shift])
    @shift.start = Time.now unless @shift.start
    unless current_user.is_admin_of?(@department) && @shift.scheduled?
      @shift.power_signed_up = false
      @shift.user = current_user
    end
    if @shift.save
      #combine with any compatible shifts (if the shift is scheduled)
      flash[:notice] = "Successfully created shift."
      redirect_to @shift
    else
      render :action => 'new'
    end
  end
  
  def ajax_create
    @shift = Shift.new(params[:shift])
    if @shift.save
      #combine with any compatible shifts (if the shift is scheduled)
      flash[:notice] = "Successfully created shift."
      #redirect_to @shift
    else
      flash[:error] = "Shift could not be saved for some reason"
      #render :action => 'new'
    end
  end

  def edit
    @shift = Shift.find(params[:id])
    (render :partial => 'shifts/tooltips/new', :layout => 'none') if params[:tooltip]
  end

  def update
    @shift = Shift.find(params[:id])
    if @shift.update_attributes(params[:shift])
      #combine with any compatible shifts
      flash[:notice] = "Successfully updated shift."
      redirect_to @shift
    else
      render :action => 'edit'
    end
  end

  def destroy
    @shift = Shift.find(params[:id])
    @shift.destroy
    flash[:notice] = "Successfully destroyed shift."
    redirect_to shifts_url
  end
end
