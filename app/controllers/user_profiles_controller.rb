class UserProfilesController < ApplicationController
before_filter :user_login
  def index
    @user_profiles = UserProfile.all
    @user_profile_entries = UserProfileEntry.all
  end

  def show
    @user_profile = UserProfile.find_by_user_id(User.find_by_login(params[:id]).id)
  end

  def new
    @user_profile = UserProfile.new
  end

  def create
    @user_profile = UserProfile.new(params[:user_profile])
    if @user_profile.save
      flash[:notice] = "Successfully created user profile."
      redirect_to @user_profile
    else
      render :action => 'new'
    end
  end

  def edit
    @user_profile = UserProfile.find_by_user_id(User.find_by_login(params[:id]).id)
    @user_profile_entries = UserProfileEntry.find(:all, :conditions => { :user_profile_id => @user_profile.id})
  end

  def update
    @user_profile = UserProfile.find(params[:id])
    @user_profile_entries = params[:user_profile_entries]
    @user_profile_entries.each do |entry_id, entry_content|
      entry = UserProfileEntry.find(entry_id)
      entry.content = entry_content[entry_id]
      entry.save
    end
      redirect_to user_profiles_path
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

