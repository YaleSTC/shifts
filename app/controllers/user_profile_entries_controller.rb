class UserProfileEntriesController < ApplicationController
  def index
    @user_profile_entries = UserProfileEntry.all
    @user_profile_fields = UserProfileField.where(department_id: @department.id)
  end

  def show
    @user_profile_fields = UserProfileField.where(department_id: @department.id)
#    @user_profile_entry = UserProfileEntry.find
  end

  def new
    @user_profile_entry = UserProfileEntry.new
    @user_profile_field = UserProfileField.find(@user_profile_entry.user_profile_field_id)
  end

  def create
    @user_profile_entry = UserProfileEntry.new(params[:user_profile_entry])
    @user_profile_field = UserProfileField.find(@user_profile_entry.user_profile_field_id)
    if @user_profile_entry.save
      flash[:notice] = "Successfully created user profile entry."
      redirect_to @user_profile_entry
    else
      render action: 'new'
    end
  end

  def edit
    @user_profile_entry = UserProfileEntry.find(params[:id])
    @user_profile_field = UserProfileField.find(@user_profile_entry.user_profile_field_id)
  end

  def update
    @user_profile_entry = UserProfileEntry.find(params[:id])
    if @user_profile_entry.update_attributes(params[:user_profile_entry])
      flash[:notice] = "Successfully updated user profile entry."
      redirect_to @user_profile_entry
    else
      render action: 'edit'
    end
  end

  def destroy
    @user_profile_entry = UserProfileEntry.find(params[:id])
    @user_profile_entry.destroy
    flash[:notice] = "Successfully destroyed user profile entry."
    redirect_to user_profile_entries_url
  end
end

