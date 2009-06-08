class PayformsController < ApplicationController
  def index
    @payforms = Payform.all
  end
  
  def show
    @payform = Payform.find(params[:id])
  end
  
  def new
    @payform = Payform.new
  end
  
  def create
    @payform = Payform.new(params[:payform])
    if @payform.save
      flash[:notice] = "Successfully created payform."
      redirect_to @payform
    else
      render :action => 'new'
    end
  end
  
  def edit
    @payform = Payform.find(params[:id])
  end
  
  def update
    @payform = Payform.find(params[:id])
    if @payform.update_attributes(params[:payform])
      flash[:notice] = "Successfully updated payform."
      redirect_to @payform
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @payform = Payform.find(params[:id])
    @payform.destroy
    flash[:notice] = "Successfully destroyed payform."
    redirect_to payforms_url
  end
end
