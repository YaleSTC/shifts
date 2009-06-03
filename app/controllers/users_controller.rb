class UsersController < ApplicationController
  def index
    @users = @department.users
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    #if user already in database
    if @user = User.find_by_netid(params[:user][:netid])
      if @user.departments.include? @department
        flash[:notice] = "This user already exists in this department!"
        redirect_to @user
      else
        @user.departments << @department
        flash[:notice] = "User successfully added to new department."
        redirect_to @user
      end
    elsif #user is a new user
      #create from LDAP if possible; otherwise just use the given information
      @user = User.import_from_ldap(params[:user][:netid], @department) || User.create(params[:user])
    
      #if a name was given, it should override the name from LDAP
      @user.name = params[:user][:name] unless params[:user][:name] == ""
      if @user.save
        flash[:notice] = "Successfully created user."
        redirect_to @user
      else
        render :action => 'new'
      end
    end
    
    y @user
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    params[:user][:role_ids] ||= []
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
    redirect_to department_users_path(current_department)
  end

  def mass_add
    #just a view
  end

  def mass_create
    errors = User.mass_add(params[:netids], @department)
    unless errors.empty?
      flash[:error] = "Import of the following users failed:<br /> "+(errors.join "<br />")
    end
    redirect_to department_users_path
  end
end

