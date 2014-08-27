class TasksController < ApplicationController
  layout 'shifts'
  # GET /tasks
  # GET /tasks.xml

  def index
    #return unless user_is_admin_of(current_department)
    @tasks = Task.all
    @active_tasks = Task.where("active = ?", true)
    @inactive_tasks = Task.where("active = ?", false)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.xml
  def show
    #return unless user_is_admin_of(current_department)
    @task = Task.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.xml
  def new
    return unless user_is_admin_of(current_department)
    @task = Task.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    return unless user_is_admin_of(current_department)
    @task = Task.find(params[:id])
  end

  # POST /tasks
  # POST /tasks.xml
  def create
    @task = Task.new(params[:task])

    respond_to do |format|
      if @task.save
        flash[:notice] = 'Task was successfully created.'
        format.html { redirect_to(params[:add_another] ? new_task_path : @task) }
        format.xml  { render xml: @task, status: :created, location: @task }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.xml
  def update
    # raise params.to_yaml
    @task = Task.find(params[:id])

    respond_to do |format|
      if @task.update_attributes(params[:task])
        flash[:notice] = 'Task was successfully updated.'
        format.html { redirect_to(@task) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.xml
  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    respond_to do |format|
      format.html { redirect_to(tasks_url) }
      format.xml  { head :ok }
    end
  end

  def make_entry
    @shift = current_user.current_shift
    @all_tasks = params[:all_tasks]
    if @all_tasks == "true"
      @tasks = all_allowed_tasks
    else
      @tasks = tasks_during_shift
    end
    task_id = params[:id]
    @shifts_task = ShiftsTask.new(task_id: task_id, shift_id: @shift ? @shift.id : nil, missed: false )
    @shifts_task.save

    if @shift #avoids error when completing tasks when not on shift
  		if @report = current_user.current_shift.report
          @report.report_items << ReportItem.new(time: Time.now, content: "#{Task.find(@shifts_task.task_id).name} completed.", ip_address: request.remote_ip)
      end
    end
    respond_to do |format|
      format.js
      format.html {redirect_to @report ? @report : @shift_task.data_object}
    end
  end

  def update_tasks
    @shift = current_user.current_shift
    @tasks = tasks_during_shift
    respond_to do |format|
      format.js
    end
  end


  def completed_tasks
    @start = interpret_start
    @end = interpret_end
    @task = Task.find(params[:id])
    @shifts = ShiftsTask.where(task_id: @task.id, missed: false)
    @shifts_tasks = @shifts.select{|st| st.created_at < @end && st.created_at > @start}
  end

  def missed_tasks
    @start = interpret_start
    @end = interpret_end
    @task = Task.find(params[:id])
    @shifts = ShiftsTask.where(task_id: @task.id, missed: true)
    @shifts_tasks = @shifts.select{|st| st.created_at < @end && st.created_at > @start}
  end

  def active_tasks
    @report = current_user.current_shift.report if current_user.current_shift
    @loc_groups = current_user.loc_groups
    tasks = []
    @loc_groups.each do |loc_group|
      tasks << loc_group.locations.map{ |loc| loc.tasks }.flatten.uniq.compact
    end
    tasks = tasks.flatten.uniq.compact
    tasks = Task.active.after_now & tasks
    # filters out daily and weekly tasks scheduled for a time later in the day
    tasks = tasks.delete_if{|t| t.kind != "Hourly" && Time.now.seconds_since_midnight < t.time_of_day.seconds_since_midnight}
    # filters out weekly tasks on the wrong day, avoids error when completing tasks when not on shift
    current_day_in_week = @report ? @report.shift.start.strftime('%a') : Time.now.strftime('%a')
    @tasks = tasks.delete_if{|t| t.kind == "Weekly" && t.day_in_week != current_day_in_week }
  end

  protected

  def tasks_during_shift
    # active, non-expired tasks
    tasks = Task.in_location(current_user.current_shift.location).active.after_now
    # filters out daily and weekly tasks scheduled for a time later in the day
    tasks = tasks.delete_if{|t| t.kind != "Hourly" && Time.now.seconds_since_midnight <= t.time_of_day.seconds_since_midnight}
    # filters out weekly tasks on the wrong day
    tasks = tasks.delete_if{|t| t.kind == "Weekly" && t.day_in_week != @shift.start.strftime("%a") }
  end

  def all_allowed_tasks
    loc_groups = current_user.loc_groups
    tasks = []
    loc_groups.each do |loc_group|
      tasks << loc_group.locations.map{ |loc| loc.tasks }.flatten.uniq.compact
    end
    tasks = tasks.flatten.uniq.compact
    tasks = Task.active.after_now & tasks
    # filters out daily and weekly tasks scheduled for a time later in the day
    tasks = tasks.delete_if{|t| t.kind != "Hourly" && Time.now.seconds_since_midnight < t.time_of_day.seconds_since_midnight}
    # filters out weekly tasks on the wrong day, avoids error when completing tasks when not on shift
    current_day_in_week = @shift ? @shift.start.strftime('%a') : Time.now.strftime('%a')
    tasks = tasks.delete_if{|t| t.kind == "Weekly" && t.day_in_week != current_day_in_week }
  end

  private

  def interpret_start
    if params[:dates]
      return Date.civil(params[:dates][:"start(1i)"].to_i,params[:dates][:"start(2i)"].to_i,params[:dates][:"start(3i)"].to_i)
    elsif params[:start]
      return params[:start].to_date
    else
      return 1.week.ago.to_date
    end
  end

  def interpret_end
    if params[:dates]
      return Date.civil(params[:dates][:"end(1i)"].to_i,params[:dates][:"end(2i)"].to_i,params[:dates][:"end(3i)"].to_i)
    elsif params[:end]
      return params[:end].to_date
    else
      return Date.today.to_date
    end
  end


end
