class UserProfilesController < ApplicationController
before_filter :user_login
  def index
    @user_profiles = UserProfile.all
    @user_profile_entries = UserProfileEntry.all
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
      entry.content = entry_content[entry_id]
      entry.save
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

private
  def user_login
    @user_profile = UserProfile.find(:all, :conditions => {:user_id => User.find_by_login(params[:id])})
  end
end

