class RequestedShiftsController < ApplicationController

  before_filter :require_proper_template_role

  def index
		@week_template = Template.find(params[:template_id])
		#copied from time_slot, some might not be necessary?
		@period_start = Date.today.previous_sunday
    #TODO:simplify this stuff:
    @dept_start_hour = current_department.department_config.schedule_start / 60
    @dept_end_hour = current_department.department_config.schedule_end / 60
    @hours_per_day = (@dept_end_hour - @dept_start_hour)
    @block_length = current_department.department_config.time_increment
    @blocks_per_hour = 60/@block_length.to_f
    @blocks_per_day = @hours_per_day * @blocks_per_hour
		#definitely remove hidden timeslots
    @hidden_timeslots = [] #for timeslots that don't show up on the view

    if current_department.department_config.weekend_shifts #show weekends
      @day_collection = (@period_start...(@period_start+7)).to_a
    else #no weekends
      @day_collection = ((@period_start+1)...(@period_start+6)).to_a
    end
		@shift_preference = current_user.shift_preferences.select{|sp| sp.template_id == @week_template.id}.first
		@requested_shift = RequestedShift.new
		@requested_shifts = current_user.requested_shifts.select{|rs| rs.template == @week_template}
    @requested_shifts = @week_template.requested_shifts if current_user.is_admin_of?(current_department)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @requested_shifts }
    end
  end

  def show
    @requested_shift = RequestedShift.find(params[:id])
		@week_template = Template.find(params[:template_id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @requested_shift }
    end
  end

  def new
		@week_template = Template.find(params[:template_id]
		@shift_preference = current_user.shift_preferences.select{|sp| sp.template_id == @week_template.id}.first
		@template_time_slots = @week_template.template_time_slots
#		If the user does not have a shift preference object for the given template, make sure they create one first
		unless @shift_preference
			flash[:notice] = 'Please set your general shift preferences first'
			redirect_to new_template_shift_preference_path(@week_template)
		end
    @requested_shift = RequestedShift.new
		@requested_shifts = current_user.requested_shifts.select{|rs| rs.template == @week_template}
    @requested_shifts = @week_template.requested_shifts if current_user.is_admin_of?(current_department)
		@department_config = @week_template.department.department_config
		@range_start_time = Time.local(2000,"jan", 1, 0, 0, 0) + @department_config.schedule_start * 60
		@range_end_time = Time.local(2000,"jan", 1, 0, 0, 0) + @department_config.schedule_end * 60
		@locations = @week_template.timeslot_locations
	end

  def edit
    @requested_shift = RequestedShift.find(params[:id])
		@week_template = Template.find(params[:template_id])
		@locations = @week_template.timeslot_locations
  end

  def create
#		raise params.to_yaml
    parse_just_time(params[:requested_shift])
    @requested_shift = RequestedShift.new(params[:requested_shift])
		@requested_shift.preferred_start = nil unless params[:preferred_start_choice]
		@requested_shift.preferred_end = nil unless params[:preferred_end_choice]
		@week_template = Template.find(params[:template_id])
		@template_time_slots = @week_template.template_time_slots
		@requested_shift.template = @week_template
		@requested_shift.user = current_user
		@locations = @requested_shift.template.timeslot_locations
		begin
			RequestedShift.transaction do
				@requested_shift.save(false)
				if params[:for_locations]
					params[:for_locations].each do |loc_id|
						@locations_requested_shift = LocationsRequestedShift.new
						@locations_requested_shift.requested_shift = @requested_shift
						@locations_requested_shift.location = Location.find(loc_id)
						@locations_requested_shift.assigned = false
						@locations_requested_shift.save
					end
				end
				@requested_shift.save!
			end
		rescue Exception => e
			@requested_shifts = current_user.requested_shifts.select{|rs| rs.template == @week_template}
		  @requested_shifts = @week_template.requested_shifts if current_user.is_admin_of?(current_department)
			respond_to do |format|
		  	format.html { render :action => "edit" }
				format.js
		  end
		else
			@week_template.requested_shifts << @requested_shift
			@requested_shifts = current_user.requested_shifts.select{|rs| rs.template == @week_template}
		  @requested_shifts = @week_template.requested_shifts if current_user.is_admin_of?(current_department)
			respond_to do |format|
				flash[:notice] = 'Requested shift was successfully created.'
				format.html { redirect_to(template_requested_shifts_path(@week_template)) }
				format.js
			end
		end
  end

  def update
		parse_just_time(params[:requested_shift])
    @requested_shift = RequestedShift.find(params[:id])
		@week_template = Template.find(params[:template_id])
		respond_to do |format|
      if @requested_shift.update_attributes(params[:requested_shift])
				if params[:assign_flag]
					@lrs = LocationsRequestedShift.where('requested_shift_id = ? AND location_id = ?', @requested_shift, Location.find(params[:assigned_location])).first
					@lrs.assigned = true
					@lrs.save
				end
        flash[:notice] = 'RequestedShift was successfully updated.'
        format.html { redirect_to(template_requested_shift_path(@week_template, @requested_shift)) }
        format.xml  { head :ok }
      else
        format.html { redirect_to(edit_template_requested_shift_path(@week_template, @requested_shift)) }
        format.xml  { render :xml => @requested_shift.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @requested_shift = RequestedShift.find(params[:id])
    @requested_shift.destroy

    respond_to do |format|
      format.html { redirect_to(:back) }
      format.xml  { head :ok }
    end
  end
end

private

  def parse_just_time(form_output)
    titles = ["preferred_start", "preferred_end", "acceptable_start","acceptable_end", "assigned_start", "assigned_end"]
    titles.each do |field_name|
      if !form_output["#{field_name}(5i)"].blank? && form_output["#{field_name}(4i)"].blank?
        form_output["#{field_name}"] = Time.local(2000,"jan", 1, form_output["#{field_name}(5i)"].split(":").first, form_output["#{field_name}(5i)"].split(":")[1], form_output["#{field_name}(5i)"].split(":").last)
      end
      form_output.delete("#{field_name}(5i)")
    end
  end

