class UserProfilesController < ApplicationController
  def index
    @user_profiles = UserProfile.all
  end
  
  def show
    @user_profile = UserProfile.find(params[:id])
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
end
