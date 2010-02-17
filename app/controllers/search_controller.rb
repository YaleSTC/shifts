class SearchController < ApplicationController
  def index
    @shift_results = ReportItem.search(params[:search_text]).map{|r| r.report.shift}
    @user_results = User.search(params[:search_text])
  end

end
