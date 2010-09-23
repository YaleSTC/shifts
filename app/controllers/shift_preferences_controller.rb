class ShiftPreferencesController < ApplicationController

  layout 'calendar'

  before_filter :require_proper_template_role

  # GET /shift_preferences
  # GET /shift_preferences.xml
  def index

    @week_template = Template.find(:first, :conditions => {:id => params[:template_id]})
    @shift_preferences = @week_template.shift_preferences

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shift_preferences }
    end
  end

  # GET /shift_preferences/1
  # GET /shift_preferences/1.xml
  def show
    @shift_preference = ShiftPreference.find(params[:id])
    @week_template = Template.find(:first, :conditions => {:id => params[:template_id]})

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @shift_preference }
    end
  end

  # GET /shift_preferences/new
  # GET /shift_preferences/new.xml
  def new
		@week_template = Template.find(:first, :conditions => {:id => params[:template_id]})
    @shift_preference = ShiftPreference.new
    @hours_week = (@week_template.min_total_hours..@week_template.max_total_hours).to_a
    @shifts_week = (@week_template.min_number_of_shifts..@week_template.max_number_of_shifts).to_a
    @hours_shift = (@week_template.min_continuous_hours..@week_template.max_continuous_hours).to_a
    @locations = @week_template.timeslot_locations
    @user_shift_preference = @week_template.shift_preferences.find_by_user_id(current_user.id)
    if @user_shift_preference
    	redirect_to edit_template_shift_preference_path(@week_template, @user_shift_preference) and return
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shift_preference }
    end
  end

  # GET /shift_preferences/1/edit
  def edit
    @week_template = Template.find(:first, :conditions => {:id => params[:template_id]})
    @shift_preference = ShiftPreference.find(params[:id])
    @hours_week = (@week_template.min_total_hours..@week_template.max_total_hours).to_a
    @shifts_week = (@week_template.min_number_of_shifts..@week_template.max_number_of_shifts).to_a
    @hours_shift = (@week_template.min_continuous_hours..@week_template.max_continuous_hours).to_a
    @locations = @week_template.locations
  end

  # POST /shift_preferences
  # POST /shift_preferences.xml
  def create
		#raise params.to_yaml
		@week_template = Template.find(:first, :conditions => {:id => params[:template_id]})
    @hours_week = (@week_template.min_total_hours..@week_template.max_total_hours).to_a
    @shifts_week = (@week_template.min_number_of_shifts..@week_template.max_number_of_shifts).to_a
    @hours_shift = (@week_template.min_continuous_hours..@week_template.max_continuous_hours).to_a
    @locations = @week_template.signup_locations
    @shift_preference = ShiftPreference.new(params[:shift_preference])
    @shift_preference.user = current_user
		@shift_preference.save(false)
		@locations.each do |current_location|
    	preference_name = "kind"+current_location.id.to_s
			if params[preference_name]
    		@locations_shift_preference = LocationsShiftPreference.new(:shift_preference_id => 	@shift_preference.id, :location_id => current_location.id, :kind => params[preference_name])
    		@locations_shift_preference.save
			end
		end
		@shift_preference
    respond_to do |format|
      if @shift_preference.save
				@week_template.shift_preferences << @shift_preference
				@week_template.save
        @locations.each do |current_location|
          preference_name = "kind"+current_location.id.to_s
          @locations_shift_preference = LocationsShiftPreference.new(:shift_preference_id => @shift_preference.id, :location_id => current_location.id, :kind => params[preference_name])
          @locations_shift_preference.save
        end
        flash[:notice] = 'Shift Preference was successfully created.'
        format.html { redirect_to(new_template_requested_shift_path(@week_template)) }
        format.xml  { render :xml => @shift_preference, :status => :created, :location => @shift_preference }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @shift_preference.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /shift_preferences/1
  # PUT /shift_preferences/1.xml
  def update
    @week_template = Template.find(:first, :conditions => {:id => params[:template_id]})
    @shift_preference = ShiftPreference.find(params[:id])
    @hours_week = (@week_template.min_total_hours..@week_template.max_total_hours).to_a
    @shifts_week = (@week_template.min_number_of_shifts..@week_template.max_number_of_shifts).to_a
    @hours_shift = (@week_template.min_continuous_hours..@week_template.max_continuous_hours).to_a
    @locations = @week_template.locations
    respond_to do |format|
      if @shift_preference.update_attributes(params[:shift_preference])
        @shift_preference.locations_shift_preferences.destroy_all
        @locations.each do |current_location|
          preference_name = "kind"+current_location.id.to_s
          @locations_shift_preference = LocationsShiftPreference.new(:shift_preference_id => @shift_preference.id, :location_id => current_location.id, :kind => params[preference_name])
          @locations_shift_preference.save
        end
        flash[:notice] = 'Shift Preference was successfully updated.'
        format.html { redirect_to(new_template_requested_shift_path(@week_template)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shift_preference.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shift_preferences/1
  # DELETE /shift_preferences/1.xml
  def destroy
    @week_template = Template.find(:first, :conditions => {:id => params[:template_id]})
    @shift_preference = ShiftPreference.find(params[:id])
    @shift_preference.destroy

    respond_to do |format|
      format.html { redirect_to(template_shift_preferences_path(@week_template)) }
      format.xml  { head :ok }
    end
  end
end

