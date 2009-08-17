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
    raise params.to_yaml
    @punch_clock_set = PunchClockSet.new(params[:id])
#    raise @punch_clock_set.punch_clocks.to_yaml
    messages = []
    @punch_clock_set.punch_clocks.each do |pc|
      if params[:pause]
        pc.pause unless pc.paused?
        messages << "wibble #{pc.id} boogle."
      elsif params[:unpause]
        pc.unpause if pc.paused?
      elsif params[:submit]  # Clocking out  
        messages <<  "Could not submit punch clock for #{pc.user}: #{pc.submit}.  "
      end
      pc.last_touched = Time.now unless params[:submit]
      pc.save if pc
    end
    flash[:error] = messages unless messages.empty?
    @punch_clock_set.destroy if @punch_clock_set.punch_clocks.empty?
    redirect_to punch_clock_sets_path
#    if @punch_clock_set.save
#      flash[:notice] = 'Mass punch clock was successfully created.'
#      failed = []      
#      flash[:warning] = "Could not clock in the following users: "
#      params[:users].remove_blank.each do |uid|
#        failed << uid unless PunchClock.create({:description => @punch_clock_set.description, 
#                                   :department => current_department, 
#                                   :user_id => uid, 
#                                   :runtime => 0, 
#                                   :last_touched => Time.now, 
#                                   :punch_clock_set_id => @punch_clock_set.id})
#      end
#    else
#      raise "squiddy!"
#    end
    
#    begin
#      PunchClock.transaction do  
#        @punch_clock_set = PunchClockSet.new(params[:punch_clock_set])
#        @punch_clock_set.department_id = current_department.id
#        @punch_clock_set.save!
#        params[:users].remove_blank.each{|uid| PunchClock.create!(:description => @punch_clock_set.description, :department => current_department, :user_id => uid, :runtime => 0, :last_touched => Time.now, :punch_clock_set_id => @punch_clock_set.id) }
#        flash[:notice] = 'Mass punch clock was successfully created.'
#      end
#      redirect_to punch_clock_sets_path
#    rescue Exception => e
#      flash[:error] = e.message
#      redirect_to :action => "new"
#    end
  end

  def destroy
    @punch_clock_set = PunchClockSet.find(params[:id])
    @punch_clock_set.destroy
    redirect_to(punch_clock_sets_url)
  end

end
