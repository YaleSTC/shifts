class ShiftPreferencesController < ApplicationController

  layout 'calendar'

  before_filter :require_proper_template_role

  def index
    @week_template = Template.find(params[:template_id])
    @shift_preferences = @week_template.shift_preferences.sort_by{|shift_preferences| [shift_preferences.user.reverse_name]}
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @shift_preferences }
    end
  end

  def show
    @shift_preference = ShiftPreference.find(params[:id])
    @week_template = Template.find(params[:template_id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @shift_preference }
    end
  end

  def new
		@week_template = Template.find(params[:template_id])
    @shift_preference = ShiftPreference.new
    @hours_week = (@week_template.min_total_hours..@week_template.max_total_hours).to_a
    @shifts_week = (@week_template.min_number_of_shifts..@week_template.max_number_of_shifts).to_a
    @hours_shift = (@week_template.min_continuous_hours..@week_template.max_continuous_hours).to_a
    @locations = @week_template.timeslot_locations
    @user_shift_preference = @week_template.shift_preferences.where(user_id: current_user.id).first
    if @user_shift_preference
    	redirect_to edit_template_shift_preference_path(@week_template, @user_shift_preference) and return
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @shift_preference }
    end
  end

  def edit
    @week_template = Template.find(params[:template_id])
    @shift_preference = ShiftPreference.find(params[:id])
    @hours_week = (@week_template.min_total_hours..@week_template.max_total_hours).to_a
    @shifts_week = (@week_template.min_number_of_shifts..@week_template.max_number_of_shifts).to_a
    @hours_shift = (@week_template.min_continuous_hours..@week_template.max_continuous_hours).to_a
    @locations = @week_template.timeslot_locations
  end

  def create
		@week_template = Template.find(params[:template_id])
    @hours_week = (@week_template.min_total_hours..@week_template.max_total_hours).to_a
    @shifts_week = (@week_template.min_number_of_shifts..@week_template.max_number_of_shifts).to_a
    @hours_shift = (@week_template.min_continuous_hours..@week_template.max_continuous_hours).to_a
    @locations = @week_template.signup_locations
    @shift_preference = ShiftPreference.new(params[:shift_preference])
    @shift_preference.user = current_user
		@shift_preference.save(validate: false)
		@locations.each do |current_location|
    	preference_name = "kind"+current_location.id.to_s
			if params[preference_name]
    		@locations_shift_preference = LocationsShiftPreference.new(shift_preference_id: 								@shift_preference.id, location_id: current_location.id, kind: params[preference_name])
    		@locations_shift_preference.save
			end
		end
    respond_to do |format|
      if @shift_preference.save
				@week_template.shift_preferences << @shift_preference
				@week_template.save
        @locations.each do |current_location|
          preference_name = "kind"+current_location.id.to_s
          @locations_shift_preference = LocationsShiftPreference.new(shift_preference_id: @shift_preference.id, location_id: current_location.id, kind: params[preference_name])
          @locations_shift_preference.save
        end
        flash[:notice] = 'Shift Preference was successfully created.'
        format.html { redirect_to(new_template_requested_shift_path(@week_template)) }
        format.xml  { render xml: @shift_preference, status: :created, location: @shift_preference }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @shift_preference.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @week_template = Template.find(params[:template_id])
    @shift_preference = ShiftPreference.find(params[:id])
    @hours_week = (@week_template.min_total_hours..@week_template.max_total_hours).to_a
    @shifts_week = (@week_template.min_number_of_shifts..@week_template.max_number_of_shifts).to_a
    @hours_shift = (@week_template.min_continuous_hours..@week_template.max_continuous_hours).to_a
    @locations = @week_template.timeslot_locations
    respond_to do |format|
      if @shift_preference.update_attributes(params[:shift_preference])
        @shift_preference.locations_shift_preferences.destroy_all
        @locations.each do |current_location|
          preference_name = "kind"+current_location.id.to_s
          @locations_shift_preference = LocationsShiftPreference.new(shift_preference_id: @shift_preference.id, location_id: current_location.id, kind: params[preference_name])
          @locations_shift_preference.save
        end
        flash[:notice] = 'Shift Preference was successfully updated.'
        format.html { redirect_to(:back) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
   @week_template = Template.find(params[:template_id])
    @shift_preference = ShiftPreference.find(params[:id])
    @shift_preference.destroy
    respond_to do |format|
      format.html { redirect_to(template_shift_preferences_path(@week_template)) }
      format.xml  { head :ok }
    end
  end
end

