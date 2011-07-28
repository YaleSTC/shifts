class PublicViewController < ApplicationController

  skip_before_filter :login_check
  skip_before_filter CASClient::Frameworks::Rails::Filter

  def index
    #@date = params[:date].to_date
		@loc_group = LocGroup.first #change later
		@locations = @loc_group.locations.active
		
  end

end

