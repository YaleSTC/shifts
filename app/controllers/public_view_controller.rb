class PublicViewController < ApplicationController

  skip_before_filter :login_check
  skip_before_filter CASClient::Frameworks::Rails::Filter

  def index
    @date = params[:date].to_date
		@cluster = Location.find_by_short_name(params[:cluster])
  end

end

