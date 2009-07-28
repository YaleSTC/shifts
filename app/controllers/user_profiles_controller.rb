class UserProfilesController < ApplicationController
before_filter :user_login
  def index
    @user_profiles = UserProfile.all
    @user_profile_entries = UserProfileEntry.all
  end

  def show
    @user_profile = UserProfile.find(params[:user_login])
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
    @user_profile = UserProfile.find(params[:id])
    @user_profile_entries = UserProfileEntry.find_by_user_profile_id(params[:id])
  end

  def update
    @user_profile = UserProfile.find(params[:id])
    if @user_profile.update_attributes(params[:user_profile])
      flash[:notice] = "Successfully updated user profile."
      redirect_to @user_profile
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user_profile = UserProfile.find(params[:id])
    @user_profile.destroy
    flash[:notice] = "Successfully destroyed user profile."
    redirect_to user_profiles_url
  end

private
  def user_login
    @user_profile = UserProfile.find(:all, :conditions => {:user_id => User.find_by_login(params[:user_login])})
  end
end

