class TemplatesController < ApplicationController
  before_filter :require_department_admin

  layout "application"
  # GET /templates
  # GET /templates.xml


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
		@template_time_slots = []
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
		raise params.to_yaml
    @week_template = Template.new(params[:template])
		@week_template.department = current_department
		@week_template.locations << Location.find(params[:for_locations]) 		if params[:for_locations]
		@week_template.roles << Role.find(params[:for_roles])		if params[:for_roles]
		if @week_template.template_time_slots.empty?
		
			respond_to do |format|
		    if @week_template.save
		      flash[:notice] = 'Template was successfully created.'
		      format.html { redirect_to(@week_template) }
		      format.xml  { render :xml => @week_template, :status => :created, :location => @week_template }
		    else
		      format.html { render :action => "new" }
		      format.xml  { render :xml => @week_template.errors, :status => :unprocessable_entity }
		    end
		  end
		end
  end

  def update
    @week_template = Template.find(params[:id])
    @week_template.locations.clear
    @week_template.roles.clear
    if params[:for_locations]
			@week_template.locations << Location.find(params[:for_locations])
			@week_template.roles << Role.find(params[:for_roles])
    end
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

  # DELETE /templates/1
  # DELETE /templates/1.xml
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

