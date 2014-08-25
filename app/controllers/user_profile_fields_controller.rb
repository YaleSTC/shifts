class UserProfileFieldsController < ApplicationController
  layout 'users'

  before_filter :require_department_admin
  def index
    @user_profile_fields = UserProfileField.all
  end

  def show
    @user_profile_field = UserProfileField.find(params[:id])
  end

  def profile
    @user_profile_fields = UserProfileField.where(department_id: @department.id)
  end

  def new
    @user_profile_field = UserProfileField.new
  end

  def create
    @user_profile_field = UserProfileField.new(params[:user_profile_field])
    @user_profile_field.department_id = @department.id
    begin
      UserProfileField.transaction do
        @user_profile_field.save
        @department.users.each do |user|
          UserProfileEntry.create!(user_profile_id: user.user_profile.id,
                                   user_profile_field_id: @user_profile_field.id)
        end
      end
      flash[:notice] = "Successfully created user profile field."
      redirect_to @user_profile_field
    rescue
      flash[:error] = "Something went wrong. Please try again."
      render action: 'new'
    end
  end

  def edit
    @user_profile_field = UserProfileField.find(params[:id])
  end

  def update
    @user_profile_field = UserProfileField.find(params[:id])
    if @user_profile_field.update_attributes(params[:user_profile_field])
      flash[:notice] = "Successfully updated user profile field."
      redirect_to @user_profile_field
    else
      render action: 'edit'
    end
  end

  def destroy
    @user_profile_field = UserProfileField.find(params[:id])
    @user_profile_field.destroy
    flash[:notice] = "Successfully destroyed user profile field."
    redirect_to user_profile_fields_url
  end
end

