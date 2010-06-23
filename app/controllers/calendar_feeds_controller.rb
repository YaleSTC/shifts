class CalendarFeedsController < ApplicationController
    skip_before_filter filter_chain, :except => {:index, :admin}
    
  def index
    shift_source = Struct.new( :type, :name, :token )
    @user=shift_source.new(current_user.class.name, current_user.name, generate_token(current_user))
    @shift_sources = [@user]
    current_user.departments.each do |department|
      @shift_sources << shift_source.new(department.class.name, department.name, generate_token(department))
    end  
    current_user.departments.each do |department|
      department.loc_groups.each do |loc_group|
        if current_user.can_view?(loc_group)
          @shift_sources << shift_source.new(loc_group.class.name, loc_group.name, generate_token(loc_group))
          loc_group.locations.each do |location|
            @shift_sources << shift_source.new(location.class.name, location.name, generate_token(location))
          end
        end
      end
     end
  end

  def reset
    current_user.calendar_feed_hash = nil
    current_user.save!
    flash[:notice] = 'All calendars reset.  NOTE: Your old feeds are now inactive'
    redirect_to :action => "index"
  end
  
  def grab
    begin
      @source = resolve_token(params[:token], params[:user_id])
      @user = User.find(params[:user_id])
    rescue Exception => e
      redirect_to :action => "index"
      flash[:error] = 'Could not load calendar feed.  This feed may be invalid, inactive, or disabled.'  
      return
    end
    @shifts = []
    case
        when @source.class.name == "Department" && @user.departments.include?(@source) && @user.is_active?(@source)
          @shifts = Shift.in_locations(@source.loc_groups.select {|lg| @user.can_view?(lg)}.collect(&:locations).flatten).after_date(Time.now.utc - 3.weeks).flatten
        when @source.class.name == "LocGroup" && @user.can_view?(@source)
          @shifts = Shift.in_locations(@source.locations).after_date(Time.now.utc - 3.weeks).flatten
        when @source.class.name == "Location" && @user.can_view?(@source.loc_group)
           @shifts = Shift.find(:all, :conditions => ["location_id = ? AND end >= ?", @source.id, Time.now.utc - 3.weeks])
        when @source.class.name == "User"
           @shifts = Shift.in_departments(@source.active_departments).for_user(@source).after_date(Time.now.utc - 3.weeks).flatten
      end
      render :text => generate_ical
  end
  
  private
  
  def generate_token(source)
    if !current_user.calendar_feed_hash
      current_user.calendar_feed_hash = SecureRandom.hex(32)  #must be 32 characters
      current_user.save!
    end
      require 'openssl'
      require 'digest/sha2'
      cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
      cipher.encrypt
      cipher.key = AppConfig.first.calendar_feed_hash      
      cipher.iv = current_user.calendar_feed_hash
      @token = cipher.update(source.class.name.to_s + ',' +  source.id.to_s)    #creates cipher from string
      @token << cipher.final
      @token.unpack("H*").to_s          #makes cipher alpa-numeric pretty
  end
  
  def resolve_token(token, user_id)
    require 'openssl'
    require 'digest/sha2'
    cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    cipher.decrypt
    cipher.key = AppConfig.first.calendar_feed_hash
      cipher.iv = User.find(user_id).calendar_feed_hash
      @source_string = cipher.update(token.to_a.pack("H*"))    #unpacks cipher and decrpts to original string
      @source_string << cipher.final
      @source_string.split(',')[0].constantize.find(@source_string.split(',')[1])     #gets shift_source from string
      #This block will failß with bad data -- but it is handled in the grab function.
  end

  def generate_ical
    cal = Icalendar::Calendar.new
    cal.custom_property("METHOD","PUBLISH")
    cal.custom_property("x-wr-calname","Shifts: " + @source.name)
    cal.custom_property("X-WR-CALDESC","Shifts Calendar Feed for user: " + @user.name + ".  The feed is " + @source.class.name.downcase + ": " + @source.name)
  # cal.custom_property("X-PUBLISHED-TTL", "PT1H")
      @shifts.each do |shift|
        @event = Icalendar::Event.new
        @event.dtstart = shift.start.to_s(:us_icaldate)
        @event.dtend = shift.end.to_s(:us_icaldate)
        @event.summary = "shift for #{shift.user.name} in #{shift.location.name}"
        @event.description = "This shift is for #{shift.user.name} in #{shift.location.name}."
        @event.location = shift.location.name
        cal.add @event
      end
      headers['Content-Type'] = "text/calendar; charset=UTF-8"
      headers['Content-Disposition'] = "inline; filename=" + User.find(params[:user_id]).name + "_calendar_feed.ics"
     # cal.publish 
      cal.to_ical
  end    
  
  
end