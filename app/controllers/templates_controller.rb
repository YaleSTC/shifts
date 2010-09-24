class TemplatesController < ApplicationController
  before_filter :require_department_admin

  def index
    @week_templates = Template.all
    @department = current_department
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @week_templates }
    end
  end

  def show
    @week_template = Template.find(params[:id])
		@requested_shifts = @week_template.requested_shifts
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @week_template }
    end
  end

  def new
    @week_template = Template.new
		@department = current_department
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @week_template }
    end
  end

  def edit
    @week_template = Template.find(params[:id])
  end

  def create
    @week_template = Template.new(params[:template])
		@week_template.department = current_department
		@week_template.public = true if params[:public]
		if params[:for_role]		
			params[:for_role].each do |role_id|
				@week_template.roles << Role.find(role_id)
			end
		end
		respond_to do |format|
		  if @week_template.save
		    flash[:notice] = 'Template was successfully created.'
				format.html { redirect_to(template_template_time_slots_path(@week_template)) }
				format.xml  { render :xml => @week_template, :status => :created, :location => @week_template }
		  else
		    format.html { render :action => "new" }
		    format.xml  { render :xml => @week_template.errors, :status => :unprocessable_entity }
		  end
		end
  end

  def update
#		raise params.to_yaml
    @week_template = Template.find(params[:id])
    @week_template.roles.clear
		@week_template.roles << Role.find(params[:for_role]) if params[:for_role]
    respond_to do |format|
      if @week_template.update_attributes(params[:template])
        flash[:notice] = 'Template was successfully updated.'
        format.html { redirect_to(@week_template) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @week_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @week_template = Template.find(params[:id])
    @week_template.destroy

    respond_to do |format|
      format.html { redirect_to(templates_url) }
      format.xml  { head :ok }
    end
  end

	def update_locations
		raise params.to_yaml
    #@week_template = Template.find(params[:roles].split(":").first)
		@locations = []
		process_roles(params[:roles]).flatten.each do |role|
			@locations << role.signup_locations
		end
		@template_time_slots = @week_template.template_time_slots
		@time_slot = TemplateTimeSlot.new
		@time_slot.save(false)
		@template_time_slots << @time_slot if @template_time_slots.empty?
		puts @locations.to_yaml
		@locations.flatten!
	end

	def add_timeslot
    @week_template = Template.find(params[:id])
		@time_slot = TemplateTimeSlot.new
		@time_slot.save(false)
		@template_time_slots = @week_template.template_time_slots
		@template_time_slots << @time_slot
	end

	def process_roles(params_roles)
		roles = params_roles.split(":").to_a
		roles.shift
		roles.split(" ").each do |role_string|
			roles << Role.find(role_string.split(":").first) if role_string.split(":").last == "true"
		end
		return roles
	end
end

