class ReportItemsController < ApplicationController
  def index
    @report_items = ReportItem.all
  end

  def show
    @report_item = ReportItem.find(params[:id])
  end

  def new
    @report_item = ReportItem.new
  end

  def create
    @report_item = ReportItem.new(params[:report_item])
    @report_item.time = Time.now
    @report_item.ip_address = request.remote_ip
    @report_item.report_id = params[:report_id]
    if @report_item.save
      flash[:notice] = "Successfully created reportitem."
      redirect_to @report_item
    else
      render :action => 'new'
    end
  end

  def edit
    @report_item = ReportItem.find(params[:id])
  end

  def update
    @report_item = ReportItem.find(params[:id])
    if @report_item.update_attributes(params[:report_item])
      flash[:notice] = "Successfully updated reportitem."
      redirect_to @report_item
    else
      render :action => 'edit'
    end
  end

  def destroy
    @report_item = ReportItem.find(params[:id])
    @report_item.destroy
    flash[:notice] = "Successfully destroyed reportitem."
    redirect_to report_items_url
  end
end
