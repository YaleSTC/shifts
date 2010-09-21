class TemplateTimeSlotsController < ApplicationController
  # GET /template_time_slots
  # GET /template_time_slots.xml
	layout 'requested_shifts'

  def index
		@week_template = Template.find(params[:template_id])
    @template_time_slots = TemplateTimeSlot.all
		@template_time_slot = TemplateTimeSlot.new
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @template_time_slots }
    end
  end

  # GET /template_time_slots/1
  # GET /template_time_slots/1.xml
  def show
    @template_time_slot = TemplateTimeSlot.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @template_time_slot }
    end
  end

  # GET /template_time_slots/new
  # GET /template_time_slots/new.xml
  def new
    @template_time_slot = TemplateTimeSlot.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @template_time_slot }
    end
  end

  # GET /template_time_slots/1/edit
  def edit
    @template_time_slot = TemplateTimeSlot.find(params[:id])
  end

  # POST /template_time_slots
  # POST /template_time_slots.xml
  def create
		raise params.to_yaml
		@week_template = Template.find(params[:template_id])
		params[:time_slot][:day].each do |day|
			if day[1] == "1"
				params[:for_locations].each do |location|
					@template_time_slot = TemplateTimeSlot.new(params[:template_time_slot])
					@template_time_slot.day = day[0].to_i
					@template_time_slot.location = Location.find(location)
					#@template_time_slot.start_time = params[:start_time(5i)]
				end
			end
		end

    respond_to do |format|
      if @template_time_slot.save
        flash[:notice] = 'Time slot successfully created.'
        format.html { redirect_to(template_template_time_slots_path(@week_template)) }
        format.xml  { render :xml => @template_time_slot, :status => :created, :location => @template_time_slot }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @template_time_slot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /template_time_slots/1
  # PUT /template_time_slots/1.xml
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

  # DELETE /template_time_slots/1
  # DELETE /template_time_slots/1.xml
  def destroy
    @template_time_slot = TemplateTimeSlot.find(params[:id])
    @template_time_slot.destroy

    respond_to do |format|
      format.html { redirect_to(template_time_slots_url) }
      format.xml  { head :ok }
    end
  end
end
