class ShiftPreferencesController < ApplicationController
  # GET /shift_preferences
  # GET /shift_preferences.xml
  def index
    @shift_preferences = ShiftPreference.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shift_preferences }
    end
  end

  # GET /shift_preferences/1
  # GET /shift_preferences/1.xml
  def show
    @shift_preference = ShiftPreference.find(params[:id])

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
    @hours_week = (3..19).to_a
    @shifts_week = (1..10).to_a
    @hours_shift = [0.25, 0.5] + (1..8).to_a
    @locations = Location.active
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shift_preference }
    end
  end

  # GET /shift_preferences/1/edit
  def edit
    @shift_preference = ShiftPreference.find(params[:id])
    @hours_week = (3..19).to_a
    @shifts_week = (1..10).to_a
    @hours_shift = [0.25, 0.5] + (1..8).to_a
    @locations = Location.active
  end

  # POST /shift_preferences
  # POST /shift_preferences.xml
  def create
		@week_template = Template.find(:first, :conditions => {:id => params[:template_id]})
    @locations = Location.active
    @shift_preference = ShiftPreference.new(params[:shift_preference])
    respond_to do |format|
      if @shift_preference.save
				@week_template.shift_preferences << @shift_preference
				@week_template.save
        @locations.each do |current_location|
          preference_name = "kind"+current_location.id.to_s
          @locations_shift_preference = LocationsShiftPreference.new(:shift_preference_id => @shift_preference.id, :location_id => current_location.id, :kind => params[preference_name])
          @locations_shift_preference.save
        end
        flash[:notice] = 'ShiftPreference was successfully created.'
        format.html { redirect_to(@shift_preference) }
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
    @shift_preference = ShiftPreference.find(params[:id])
    @locations = Location.active
    respond_to do |format|
      if @shift_preference.update_attributes(params[:shift_preference])
        @locations.each do |current_location|
          preference_name = "kind"+current_location.id.to_s
          @locations_shift_preference = LocationsShiftPreference.find(:first, :conditions => {:shift_preference_id => @shift_preference.id, :location_id => current_location.id})
          @locations_shift_preference.kind = params[preference_name]
          @locations_shift_preference.save!
        end
        flash[:notice] = 'ShiftPreference was successfully updated.'
        format.html { redirect_to(@shift_preference) }
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
    @shift_preference = ShiftPreference.find(params[:id])
    @shift_preference.destroy

    respond_to do |format|
      format.html { redirect_to(shift_preferences_url) }
      format.xml  { head :ok }
    end
  end
end
