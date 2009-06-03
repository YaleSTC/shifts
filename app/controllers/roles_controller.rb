class RolesController < ApplicationController
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
      redirect_to @role
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
    redirect_to department_roles_path(current_department)
  end
end

