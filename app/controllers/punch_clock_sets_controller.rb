class PunchClockSetsController < ApplicationController
  layout "payforms"

  helper :punch_clocks

  before_filter :require_department_admin

  def index
    @punch_clock_sets = PunchClockSet.all
  end

  def new
    @punch_clock_set = PunchClockSet.new
    @users_select = current_department.active_users.sort_by(&:name)
  end

  def create
    @punch_clock_set = PunchClockSet.new(params[:punch_clock_set])
    @punch_clock_set.department = current_department
    if @punch_clock_set.save
      flash[:notice] = "Mass punch clock was successfully created."
      failed = []      
      params[:users].remove_blank.each do |uid|
        clock = PunchClock.new({:description => @punch_clock_set.description, 
                                :department => current_department, 
                                :user_id => uid, 
                                :runtime => 0, 
                                :last_touched => Time.now, 
                                :punch_clock_set_id => @punch_clock_set.id})
        failed << User.find(uid).name unless clock.save
      end
      flash[:warning] = "Could not clock in the following users: #{failed.to_sentence}." unless failed.empty?
      redirect_to :action => :index
    else
      @users_select = current_department.active_users.sort_by(&:name)
      render :action => :new
    end
  end

  def update
    @punch_clock_set = PunchClockSet.find(params[:id])
    messages = []
    @punch_clock_set.punch_clocks.each do |pc|
      if params[:pause]
        error = pc.pause unless pc.paused?
        messages << "Could not pause #{pc.user.name}'s clock." if error
      elsif params[:unpause]
        error = pc.unpause if pc.paused?
        messages << "Could not unpause #{pc.user.name}'s clock." if error        
      elsif params[:submit]  # Clocking out 
        messages <<  "Could not submit #{pc.user}'s clock: #{pc.submit}." if pc.submit 
        @punch_clock_set.reload
      end
      pc.last_touched = Time.now unless params[:submit]
      pc.save if pc
    end
    flash[:error] = messages.join("  ") unless messages.empty?
    flash[:notice] = "Submitted all clocks." if @punch_clock_set.punch_clocks.empty? && @punch_clock_set.destroy 
    redirect_to punch_clock_sets_path
  end

# Should be refactored to use :dependent => :destroy, but unsure if that works when
# the presence of the parent is optional.  Must investigate.  -ben
  def destroy
    @punch_clock_set = PunchClockSet.find(params[:id])
    @punch_clock_set.punch_clocks.each {|clock| clock.destroy}
    @punch_clock_set.destroy
    redirect_to(punch_clock_sets_url)
  end

end
