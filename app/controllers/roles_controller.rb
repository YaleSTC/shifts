class RolesController < ApplicationController
  before_filter :load_department

  def index
    @roles = Role.all
  end

  def show
    @role = Role.find(params[:id])
  end

  # allow a selection of permissions
  def new
    @role = Role.new
  end

  def create
    @role = Role.new(params[:role])
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
    redirect_to roles_url
  end

  private
  def load_department
    @department = Department.find(params[:department_id])
  end
end

