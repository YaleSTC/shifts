class UserShiftPreferencesController < ApplicationController
  # GET /user_shift_preferences
  # GET /user_shift_preferences.xml
  def index
    @user_shift_preferences = UserShiftPreference.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_shift_preferences }
    end
  end

  # GET /user_shift_preferences/1
  # GET /user_shift_preferences/1.xml
  def show
    @user_shift_preference = UserShiftPreference.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_shift_preference }
    end
  end

  # GET /user_shift_preferences/new
  # GET /user_shift_preferences/new.xml
  def new
    @user_shift_preference = UserShiftPreference.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_shift_preference }
    end
  end

  # GET /user_shift_preferences/1/edit
  def edit
    @user_shift_preference = UserShiftPreference.find(params[:id])
  end

  # POST /user_shift_preferences
  # POST /user_shift_preferences.xml
  def create
    @user_shift_preference = UserShiftPreference.new(params[:user_shift_preference])

    respond_to do |format|
      if @user_shift_preference.save
        flash[:notice] = 'UserShiftPreference was successfully created.'
        format.html { redirect_to(@user_shift_preference) }
        format.xml  { render :xml => @user_shift_preference, :status => :created, :location => @user_shift_preference }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_shift_preference.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_shift_preferences/1
  # PUT /user_shift_preferences/1.xml
  def update
    @user_shift_preference = UserShiftPreference.find(params[:id])

    respond_to do |format|
      if @user_shift_preference.update_attributes(params[:user_shift_preference])
        flash[:notice] = 'UserShiftPreference was successfully updated.'
        format.html { redirect_to(@user_shift_preference) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_shift_preference.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_shift_preferences/1
  # DELETE /user_shift_preferences/1.xml
  def destroy
    @user_shift_preference = UserShiftPreference.find(params[:id])
    @user_shift_preference.destroy

    respond_to do |format|
      format.html { redirect_to(user_shift_preferences_url) }
      format.xml  { head :ok }
    end
  end
end
