class TemplateTimeSlotsController < ApplicationController
	layout 'requested_shifts'

  def index
		@week_template = Template.find(params[:template_id])
    @template_time_slots = @week_template.template_time_slots
		@template_time_slot = TemplateTimeSlot.new
		@department_config = @week_template.department.department_config
		@start = Time.local(2000,"jan", 1, @department_config.schedule_start.to_s.insert(-3," ").split.first, 	 @department_config.schedule_start.to_s.insert(-3," ").split.last,1)
		@end = Time.local(2000,"jan", 1, @department_config.schedule_end.to_s.insert(-3," ").split.first, @department_config.schedule_end.to_s.insert(-3," ").split.last,1)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @template_time_slots }
    end
  end

  def show
    @template_time_slot = TemplateTimeSlot.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @template_time_slot }
    end
  end

  def new
    @template_time_slot = TemplateTimeSlot.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @template_time_slot }
    end
  end

  def edit
    @template_time_slot = TemplateTimeSlot.find(params[:id])
  end

  def create
		parse_just_time(params[:template_time_slot])
	#raise params.to_yaml
		@week_template = Template.find(:first, :conditions => {:id => params[:template_id]})
		begin
			TemplateTimeSlot.transaction do
				params[:template_time_slot][:day].each do |day|
					if day[1] == "1"
						params[:for_locations].each do |location|
							@template_time_slot = TemplateTimeSlot.new(params[:template_time_slot])
							@template_time_slot.day = day[0].to_i
							@template_time_slot.location = Location.find(location)
							@template_time_slot.template = @week_template
							puts "made it here!"
							@template_time_slot.save
							puts "made it here!2"
						end
					end
				end
			end
		rescue Exception
		@template_time_slots = @week_template.template_time_slots
	#	raise @template_time_slots.to_yaml
		  respond_to do |format|

				format.html { redirect_to(template_template_time_slots_path(@week_template)) }
				format.js
		  end
		else
		@template_time_slots = @week_template.template_time_slots
		  respond_to do |format|

				flash[:notice] = 'Time slot successfully created.'
				format.html { redirect_to(template_template_time_slots_path(@week_template)) }
				format.xml  { render :xml => @template_time_slot, :status => :created, :location => @template_time_slot }
				format.js
			end
		end
  end

  def update
    @template_time_slot = TemplateTimeSlot.find(params[:id])

    respond_to do |format|
      if @template_time_slot.update_attributes(params[:template_time_slot])
        flash[:notice] = 'TemplateTimeSlot was successfully updated.'
        format.html { redirect_to(@template_time_slot) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @template_time_slot.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @template_time_slot = TemplateTimeSlot.find(params[:id])
		@week_template = @template_time_slot.template
    @template_time_slot.destroy

    respond_to do |format|
      format.html { redirect_to(template_template_time_slots_path(@week_template)) }
      format.xml  { head :ok }
    end
  end

private
	def parse_just_time(form_output)
    titles = ["start_time", "end_time"]
    titles.each do |field_name|
      if !form_output["#{field_name}(5i)"].blank? && form_output["#{field_name}(4i)"].blank?
        form_output["#{field_name}"] = Time.local(2000,"jan", 1, form_output["#{field_name}(5i)"].to_s.insert(-3," ").split.first, form_output["#{field_name}(5i)"].to_s.insert(-3," ").split.last,1)
      end
      form_output.delete("#{field_name}(5i)")
    end
  end
end
