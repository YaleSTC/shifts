class CalendarFeedsController < ApplicationController
  

  def index
    #define the shift sources, and cycle through returning sources user has permissions for
    #group these sources in array, generate links for each one, and then send to view w/ name and link
  end

  def grab
  respond_to do |format|
    format.ics  { render :text => self.generate_ical }
   # format.xml  { render :xml => @calendar_feeds }
  end
  end


  private
  def self.generate_token(source_class, source_id)
    
      #code to generate token using encryptor gem
  
  end
  def self.resolve_token(token)
    
      #code to resolve token using encryptor gem
      
  end

  def self.generate_ical
   @token_string = resolve_token(token)  #from routes table 
   @user = Users.find(user_id)           #from routes table
   
   #check if the user from user_id still has access to shift_source
   #return all shifts within certain date range
   #generate ical using icalendar gem

  #  cal = Icalendar::Calendar.new
  #    @cal_feed.each do |shift|
   #     event = Icalendar::Event.new
   #     event.start = shift.start
   #     event.end = shift.end
   #     event.summary = "testing" + shift.user.name.to_s
    #    cal.add event
    #  end

      # return the calendar as a string
      #cal.to_ical
  end
end
