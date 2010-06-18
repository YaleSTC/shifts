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
    @source = resolve_token(params[:token])
    @user = User.find(params[:user_id])

    # @shifts = @source.get_viewable_shifts(@user)     #model after shifts/calendar logic we already have
    @shifts = Shift.find(:all, :conditions => ["end >= ?", Time.now])
    render :text => generate_ical
    
  end


  private
  
  def generate_token(source)
    if current_user.calendar_feed_hash.blank?
      current_user.calendar_feed_hash = SecureRandom.hex(25)
    end
      #Encryptor.encrypt(source.class.name + "," + source.id.to_s, :key => current_user.calendar_feed_hash)
      1234567890
  end
  
  def resolve_token(token)
   # @decrypted_value = Encryptor.decrypt(:value => encrypted_value, :key => secret_key) 
   # @decrypted_value.split('.')[0].constantize.find(@decrypted_value.split('.')[1])
   Department.first
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