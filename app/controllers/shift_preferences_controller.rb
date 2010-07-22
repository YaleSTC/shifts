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
    @shift_preference = ShiftPreference.new
    @hours_week = (3..19).to_a
    @shifts_week = (1..10).to_a
    @hours_shift = [0.25, 0.5] + (1..8).to_a

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shift_preference }
    end
  end

  # GET /shift_preferences/1/edit
  def edit
    @shift_preference = ShiftPreference.find(params[:id])
  end

  # POST /shift_preferences
  # POST /shift_preferences.xml
  def create
    @shift_preference = ShiftPreference.new(params[:shift_preference])

    respond_to do |format|
      if @shift_preference.save
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

    respond_to do |format|
      if @shift_preference.update_attributes(params[:shift_preference])
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
