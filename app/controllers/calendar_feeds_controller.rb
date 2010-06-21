class CalendarFeedsController < ApplicationController
    skip_before_filter :load_app_config, :login_check, :except => :index
    
  def index
    shift_source = Struct.new( :type, :name, :token )
    @user=shift_source.new(current_user.class.name, current_user.name, generate_token(current_user))
    @shift_sources = [@user]
    current_user.departments.each do |department|
      @shift_sources << shift_source.new(department.class.name, department.name, generate_token(department))
    end  
    current_user.departments.each do |department|
      department.locations.each do |location|
        @shift_sources << shift_source.new(location.class.name, location.name, generate_token(location))
      end
     end
  end

  def grab
    @source = resolve_token(params[:token], params[:user_id])
    @shifts = @source.shifts
    #need to recheck permissions here incase revoked
    render :text => generate_ical
  end
  
  private
  
  def generate_token(source)
    if !current_user.calendar_feed_hash
      current_user.calendar_feed_hash = SecureRandom.hex(32)    #must be 32 char long to match cipher algorithm
      current_user.save!
    end
      require 'openssl'
      require 'digest/sha2'
      cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
      cipher.encrypt
      cipher.key = "gd345z68k223h70xkcdgd345z68k223h"       #this should become a global variable. create at setup, 32 char
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
    cipher.key = "gd345z68k223h70xkcdgd345z68k223h"
    cipher.iv = User.find(user_id).calendar_feed_hash
    @source_string = cipher.update(token.to_a.pack("H*"))    #unpacks cipher and decrpts to original string
    @source_string << cipher.final
    @source_string.split(',')[0].constantize.find(@source_string.split(',')[1])     #gets shift_source from string
      # Will FAIL with bad data
  end

  def generate_ical
    cal = Icalendar::Calendar.new
    cal.custom_property("METHOD","PUBLISH")
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
      cal.publish 
      cal.to_ical
  end    
  
  
end