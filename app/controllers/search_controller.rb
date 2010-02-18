class SearchController < ApplicationController
  def index
    @report_item_results = ReportItem.search(params[:search_text])
    @shift_results = @report_item_results.map{|r| r.report.shift}
    
    @user_results = User.search(params[:search_text])
  end

end
