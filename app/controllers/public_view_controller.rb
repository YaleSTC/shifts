class PublicViewController < ApplicationController

  skip_before_filter :login_check
  skip_before_filter CASClient::Frameworks::Rails::Filter
  helper :shifts
  helper :loc_groups
  
  def index
    #@date = params[:date].to_date
    @loc_groups = LocGroup.find(:all, :conditions => ["#{:public} = ?", true])
    @view_days = (Date.today..Date.today+7)
  end

end

