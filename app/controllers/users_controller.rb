class UsersController < ApplicationController
  def index
    @users = current_department.users
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = current_department.users.build
  end

  def create
    @user = User.create(params[:user])
    @user.departments << current_department
    y @user
    if @user.save
      flash[:notice] = "Successfully created user."
      redirect_to @user
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated user."
      redirect_to @user
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = "Successfully destroyed user."
    redirect_to users_url
  end

  def mass_add
  end

  def mass_create
    errors = User.mass_add(params[:netids])
    unless errors.empty?
      flash[:error] = "Import of the following users failed:<br /> "+(errors.join "<br />")
    end
    redirect_to users_path
  end
end

