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
    #create from LDAP if possible; otherwise just use the given information
    unless @user = User.import_from_ldap(params[:user][:netid], @department)
      @user = User.create(params[:user])
    end
    
    #if a name was given, it should override the name from LDAP
    @user.name = params[:user][:name] unless params[:user][:name] == ""
    
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

  def deactivate

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

