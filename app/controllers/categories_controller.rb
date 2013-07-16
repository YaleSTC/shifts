class CategoriesController < ApplicationController
  helper "payforms"
  layout "payforms"
  
  before_filter :require_department_admin
  
  def index
    @categories = current_department.categories
    @category = Category.new
  end

  def show
    @category = Category.find(params[:id])
  end

  def create
    @category = Category.new(params[:category])
    @category.department = current_department
    if @category.save
      flash[:notice] = "Successfully created category."
      redirect_to @category
    else
      render :action => 'new'
    end
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    if @category.update_attributes(params[:category])
      flash[:notice] = "Successfully updated category."
      redirect_to @category
    else
      render :action => 'edit'
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    flash[:notice] = "Successfully destroyed category."
    redirect_to department_categories_path(current_department)
  end
  
  def disable
    @category = Category.find(params[:id])
    @category.active = false
    @category.save!
    redirect_to :back
  end
  
  def enable
    @category = Category.find(params[:id])
    @category.active = true
    @category.save!
    redirect_to :back
  end
  
end

