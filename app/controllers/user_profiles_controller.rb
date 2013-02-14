class UserProfilesController < ApplicationController
before_filter :user_login
  def index
    @user_profiles = []
    @user_profiles = UserProfile.all.select{|profile| profile.user.is_active?(@department)}.sort_by{|profile| profile.user.reverse_name}
    @user_profile_fields =  UserProfileField.find(:all, :conditions => {:index_display => true, :department_id => @department.id})
  end

  def show
    @user = User.find_by_login(params[:id])
    @user_profile = UserProfile.find_by_user_id(@user.id)
    unless @user_profile.user.departments.include?(@department)
      flash[:error] = "This user does not have a profile in this department."
    end
    @user_profile_entries = @user_profile.user_profile_entries.select{ |entry| entry.user_profile_field.department_id == @department.id && entry.user_profile_field.public }

  end

  def new
    @user_profile = UserProfile.new
  end

  def create
    @user_profile = UserProfile.new(params[:user_profile])
    if @user_profile.save
      flash[:noticcurrent_user.is_admin_of(@department)] = "Successfully created user profile."
      if params[:user_profile] && params[:user_profile][:photo]
        render :action => 'crop'
      else
        redirect_to @user_profile
      end
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find_by_login(params[:id])
    @user_profile = UserProfile.find_by_user_id(@user.id)
    
    #The dept admin can edit all parts of any profile in their department, and a regular user can only edit their own profile entries that are user editable
    if current_user.is_admin_of?(@department)
      @user_profile_entries = @user_profile.user_profile_entries.select{ |entry| entry.user_profile_field.department_id == @department.id }
    elsif @user_profile.user == current_user
      @user_profile_entries = @user_profile.user_profile_entries.select{ |entry| entry.user_profile_field.department_id == @department.id && entry.user_profile_field.user_editable }
    else
      flash[:error] = "You are not allowed to edit another user's profile."
      redirect_to access_denied_path
    end
  end

  def update
    @user_profile = UserProfile.find(params[:id])
    @user_profile.update_attributes(params[:user_profile]) #necessary for profile pics to save 

    @user = User.find(@user_profile.user_id)
    
    if crop_errors
      flash[:error] = "Cropping failed, please try again."
      render :action => 'crop' and return
    end
      
    if params[:user_profile_entries]
      begin
        UserProfile.transaction do
          @failed = []
          @user_profile_entries = params[:user_profile_entries]
          @user_profile_entries.each do |entry_id, entry_content|
            entry = UserProfileEntry.find(entry_id)
            @content = ""
            if entry.display_type == "check_box"
              UserProfileEntry.find(entry_id).values.split(", ").each do |value|
                c = entry_content[value]
                @content += value + ", " if c == "1"
              end
            @content.gsub!(/, \Z/, "")
            entry.content = @content
            @failed << entry.field_name unless entry.save

            elsif entry.display_type == "radio_button"
              entry.content = entry_content["1"]
              @failed << entry.field_name unless entry.save
            else
              entry.content = entry_content[entry_id]
              @failed << entry.field_name unless entry.save
            end
          end
        end
      rescue
        flash[:error] = @failed.to_sentence + " all failed to save."
      end
    end
    
    #If user uploaded a new photo, crop it
    if params[:user_profile] && params[:user_profile][:photo]
      render :action => 'crop'
    else
      redirect_to user_profile_path(@user.login)
    end
  end

  def destroy
    @user_profile = UserProfile.find(params[:id])
    @user_profile.destroy
    flash[:notice] = "Successfully destroyed user profile."
    redirect_to user_profiles_url
  end

  def search
    @user_profile_fields =  UserProfileField.find(:all, :conditions => {:index_display => true, :department_id => @department.id})
    users = current_department.active_users
    #filter results if we are searching
    if params[:search]
      params[:search] = params[:search].downcase
      search_result = []
      users.each do |user|
        if user.login.downcase.include?(params[:search]) or user.name.downcase.include?(params[:search])
          search_result << user
        end
      end
      users = search_result.sort_by(&:last_name)
    end
    @user_profiles = []
    for user in users
      @user_profiles << UserProfile.find_by_user_id(user.id)
    end
  end

  def facebook
    @user_profiles = []
    @user_profiles = UserProfile.all.select{|profile| profile.user.is_active?(@department)}.sort_by{|profile| profile.user.name}
  end
  
  private
  def user_login
    @user_profile = UserProfile.find(:all, :conditions => {:user_id => User.find_by_login(params[:id])})
  end
  
  def crop_errors
    return params[:user_profile] && (params[:user_profile][:crop_w] == "0" or params[:user_profile][:crop_h] == "0")
  end
  
end

