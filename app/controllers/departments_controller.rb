class DepartmentsController < ApplicationController
  def index
    @departments = Department.all
  end
  
  def show
    @department = Department.find(params[:id])
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
