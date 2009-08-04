class UserProfilesController < ApplicationController
before_filter :user_login
  def index
    @user_profiles = UserProfile.all.select{|profile| profile.user.departments.include?(@department) }
  end

  def show
    @user_profile = UserProfile.find_by_user_id(User.find_by_login(params[:id]).id)
    @user_profile_entries = @user_profile.user_profile_entries.select{ |entry| entry.user_profile_field.department_id == @department.id && entry.user_profile_field.public }

  end

  def new
    @user_profile = UserProfile.new
  end

  def create
    @user_profile = UserProfile.new(params[:user_profile])
    if @user_profile.save
      flash[:noticcurrent_user.is_admin_of(@department)] = "Successfully created user profile."
      redirect_to @user_profile
    else
      render :action => 'new'
    end
  end

  def edit
    @user_profile = UserProfile.find_by_user_id(User.find_by_login(params[:id]).id)

    if @user_profile.user == current_user && current_user.is_admin_of?(@department)
       @user_profile_entries = @user_profile.user_profile_entries.select{ |entry| entry.user_profile_field.department_id == @department.id }
     elsif @user_profile.user == current_user
      @user_profile_entries = @user_profile.user_profile_entries.select{ |entry| entry.user_profile_field.department_id == @department.id && entry.user_profile_field.user_editable }
     elsif current_user.is_admin_of?(@department)
      @user_profile_entries = @user_profile.user_profile_entries.select{ |entry| entry.user_profile_field.department_id == @department.id && !entry.user_profile_field.user_editable }
    else
      flash[:error] = "You are not allowed to access that profile."
      redirect_to access_denied_path
    end
  end

  def update
    @user_profile = UserProfile.find(params[:id])
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
          entry.save
        elsif entry.display_type == "radio_button"
          entry.content = entry_content["1"]
          entry.save
        else
          entry.content = entry_content[entry_id]
          entry.save
        end
    end
      flash[:notice] = "Successfully edited user profile."
      redirect_to :controller => "user_profiles", :action => "show", :params => {:id => @user_profile.user.login}
  end

  def destroy
    @user_profile = UserProfile.find(params[:id])
    @user_profile.destroy
    flash[:notice] = "Successfully destroyed user profile."
    redirect_to user_profiles_url
  end

  def search
    users = current_department.users
    #filter results if we are searching
    if params[:search]
      params[:search] = params[:search].downcase
      @search_result = []
      users.each do |user|
        if user.login.downcase.include?(params[:search]) or user.name.downcase.include?(params[:search])
          @search_result << user
        end
      end
      users = @search_result.sort_by(&:last_name)
    end
    @user_profiles = []
    for user in users
      @user_profiles << UserProfile.find_by_user_id(user.user_id)
    end
  end
private
  def user_login
    @user_profile = UserProfile.find(:all, :conditions => {:user_id => User.find_by_login(params[:id])})
  end
end

