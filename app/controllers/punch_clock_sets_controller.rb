class PunchClockSetsController < ApplicationController
  layout "payforms"
  
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

#  def edit
#    @punch_clock_set = PunchClockSet.find(params[:id])
#  end

  def create
    begin
      PunchClock.transaction do  
        @punch_clock_set = PunchClockSet.new(params[:punch_clock_set])
        @punch_clock_set.department_id = current_department.id
        @punch_clock_set.save!
        params[:users].remove_blank.each{|uid| PunchClock.create!(:description => @punch_clock_set.description, :department => current_department, :user_id => uid, :runtime => 0, :last_touched => Time.now) }
        flash[:notice] = 'Mass punch clock was successfully created.'
      end
      redirect_to punch_clock_sets_path
    rescue Exception => e
      flash[:error] = e.message
      redirect_to :action => "new"
    end
  end

  def update
    @punch_clock_set = PunchClockSet.find(params[:id])
    if @punch_clock_set.update_attributes(params[:punch_clock_set])
      flash[:notice] = 'PunchClockSet was successfully updated.'
      redirect_to punch_clock_sets_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @punch_clock_set = PunchClockSet.find(params[:id])
    @punch_clock_set.destroy
    redirect_to(punch_clock_sets_url)
  end

end
