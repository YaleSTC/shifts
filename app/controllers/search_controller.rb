class SearchController < ApplicationController
  def index
    @report_item_results = ReportItem.search(params[:search_text])
    @shift_results = @report_item_results.map{|r| r.report.shift}.uniq
    
    @results_hash = {}
    @shift_results.each do |s|
      @results_hash[s] = @report_item_results.select{|r| r.report.shift == s}
    end
    
    @user_results = User.search(params[:search_text])
  end

end
