class RolesController < ApplicationController
  before_filter :require_admin_or_superuser
  layout 'users'

  def index
    @roles = @department.roles
  end

  def show
    @role = Role.find(params[:id])
  end

  # allow a selection of permissions
  def new
    @role = @department.roles.build
  end

  def create
    @role = Role.new(params[:role])
    @role.department = @department
    if @role.save
      flash[:notice] = "Successfully created role."
      redirect_to department_roles_path(@department)
    else
      render :action => 'new'
    end
  end

  def edit
    @role = Role.find(params[:id])
  end

  def update
    params[:role][:permission_ids] ||= []
    @role = Role.find(params[:id])
    if @role.update_attributes(params[:role])
      flash[:notice] = "Successfully updated role."
      redirect_to @role
    else
      render :action => 'edit'
    end
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy
    flash[:notice] = "Successfully destroyed role."
    redirect_to department_roles_path(@department)
  end
  
  #returns all of the users for a given role
  def users
    @role = Role.find(params[:id])
    @role_users =  Role.find(params[:id]).users
  end
  
  
private 

  def require_admin_or_superuser
    redirect_to(access_denied_path) unless current_user.is_admin_of?(current_department) || current_user.is_superuser?
  end
end

