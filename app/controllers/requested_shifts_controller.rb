class RequestedShiftsController < ApplicationController
  # GET /requested_shifts
  # GET /requested_shifts.xml
  def index
    @requested_shifts = RequestedShift.all
		@week_template = Template.find(:first, :conditions => {:id => params[:template_id]})
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @requested_shifts }
    end
  end

  # GET /requested_shifts/1
  # GET /requested_shifts/1.xml
  def show
    @requested_shift = RequestedShift.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @requested_shift }
    end
  end

  def new
    @requested_shift = RequestedShift.new
		#Rails will throw an error if you use @template
		@template2 = Template.find(:first, :conditions => {:id => params[:template_id]})
		@locations = @template2.locations
	end

  def edit
    @requested_shift = RequestedShift.find(params[:id])
		@template2 = Template.find(:first, :conditions => {:id => params[:template_id]})
		@locations = @template2.locations
  end

  def create
    @requested_shift = RequestedShift.new(params[:requested_shift])
		@template2 = Template.find(:first, :conditions => {:id => params[:template_id]})
		@locations = @template2.locations
		if params[:for_locations]
			@requested_shift.locations << Location.find(params[:for_locations]) 
		end	
		@requested_shift.user = current_user
		@requested_shift.template = @template2
    respond_to do |format|
      if @requested_shift.save
				@template2.requested_shifts << @requested_shift
        flash[:notice] = 'Requested shift was successfully created.'
        format.html { redirect_to(@requested_shift) }
        format.xml  { render :xml => @requested_shift, :status => :created, :location => @requested_shift }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @requested_shift.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /requested_shifts/1
  # PUT /requested_shifts/1.xml
  def update
    @requested_shift = RequestedShift.find(params[:id])

    respond_to do |format|
      if @requested_shift.update_attributes(params[:requested_shift])
        flash[:notice] = 'RequestedShift was successfully updated.'
        format.html { redirect_to(@requested_shift) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @requested_shift.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /requested_shifts/1
  # DELETE /requested_shifts/1.xml
  def destroy
    @requested_shift = RequestedShift.find(params[:id])
    @requested_shift.destroy

    respond_to do |format|
      format.html { redirect_to(requested_shifts_url) }
      format.xml  { head :ok }
    end
  end
end
