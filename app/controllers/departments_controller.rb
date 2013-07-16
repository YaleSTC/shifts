class DepartmentsController < ApplicationController
  skip_before_filter :load_department
  before_filter :require_superuser
  
  def index
    if params[:department_id]
      redirect_to Department.find(params[:department_id])
    end
    @departments = Department.all
  end

  def show
    redirect_to department_users_path(params[:id])
  end

  def new
    @department = Department.new
  end

  def create
    @department = Department.new(params[:department])
    if @department.save
      flash[:notice] = "Successfully created department."
      redirect_to @department
    else
      render :action => 'new'
    end
  end

  def edit
    @department = Department.find(params[:id])
  end

  def update
    @department = Department.find(params[:id])
    if @department.update_attributes(params[:department])
      flash[:notice] = "Successfully updated department."
      redirect_to @department
    else
      render :action => 'edit'
    end
  end

  def destroy
    @department = Department.find(params[:id])
    @department.destroy
    flash[:notice] = "Successfully destroyed department."
    redirect_to departments_url
  end

end

