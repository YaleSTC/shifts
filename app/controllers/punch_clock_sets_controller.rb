class PunchClockSetsController < ApplicationController
  layout "payforms"

  helper :punch_clocks

  
  before_filter :require_department_admin

  def index
    @punch_clock_sets = PunchClockSet.all
  end

#  def show
#    @punch_clock_set = PunchClockSet.find(params[:id])
#  end

  def new
    @punch_clock_set = PunchClockSet.new
    @users_select = current_department.users.sort_by(&:name)
  end

  def create
    @punch_clock_set = PunchClockSet.new(params[:punch_clock_set])
    @punch_clock_set.department_id = current_department.id
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
      flash[:error] = "Mass punch clock could not be created."
      redirect_to :action => :new
    end
  end

  def update
    @punch_clock_set = PunchClockSet.find(params[:id])
    messages = []
    @punch_clock_set.punch_clocks.each do |pc|
      if params[:pause]
        pc.pause unless pc.paused?
        messages << "Could not pause #{pc.user.name}"
      elsif params[:unpause]
        pc.unpause if pc.paused?
      elsif params[:submit]  # Clocking out 
        messages <<  "Could not submit punch clock for #{pc.user}: #{pc.submit}" if pc.submit 
      end
      pc.last_touched = Time.now unless params[:submit]
      pc.save if pc
    end
    flash[:error] = messages unless messages.empty?
    @punch_clock_set.destroy if @punch_clock_set.punch_clocks.empty? # Not yet working, needs more testing
    redirect_to punch_clock_sets_path
  end

  def destroy
    @punch_clock_set = PunchClockSet.find(params[:id])
    @punch_clock_set.destroy
    redirect_to(punch_clock_sets_url)
  end

end
