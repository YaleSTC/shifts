class CalendarFeedsController < ApplicationController
  

  def index
    shift_source = Struct.new( :type, :name, :token )
    @user=shift_source.new(current_user.class.name, current_user.name, generate_token(current_user))
    @shift_sources = [@user]
    current_user.departments.each do |department|
      @shift_sources << shift_source.new(department.class.name, department.name, generate_token(department))
    end  
  end

  def grab
    @source = resolve_token(params[:token], params[:user_id])
    @user = User.find(params[:user_id])

    # @shifts = @source.get_viewable_shifts(@user)     #model after shifts/calendar logic we already have
    @shifts = Shift.find(:all, :conditions => ["end >= ?", Time.now])
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
      cipher.key = "gd345z68k223h70xkcdgd345z68k223h"
      cipher.iv = current_user.calendar_feed_hash
      @token = cipher.update(source.class.name.to_s + ',' +  source.id.to_s)
      @token << cipher.final
      @token.unpack("H*")
  end
  
  def resolve_token(token, user_id)
    require 'openssl'
    require 'digest/sha2'
    cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    cipher.decrypt
    cipher.key = "gd345z68k223h70xkcdgd345z68k223h"
    cipher.iv = User.find(user_id).calendar_feed_hash
    @token=token.to_a.pack("H*")

    @source_string = cipher.update(@token)
    @source_sting << cipher.final
    @source_string.split('.')[0].constantize.find(@decrypted_value.split('.')[1])   #this will fail ugly with bad url
  end

  def generate_ical

    cal = Icalendar::Calendar.new
      @shifts.each do |shift|
        # create the event for this tool
        event = Icalendar::Event.new
        event.start = shift.start
        event.end = shift.end
        event.summary = "testing" + shift.user.name.to_s
        cal.add event
      end
      
      cal.to_ical
  end
end