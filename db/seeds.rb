# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Daley', city: cities.first)

require 'faker'
require 'ruby-progressbar'

# Number of records
NLoc_group = 2
NLocation_per_group = 3
NUser = 20
NAnnouncement = 6
NSticky = 10
NLink = 10
NNotice_department_wide = 1
NShift_per_day_per_location = 3
NTasks_per_location = 5
NData_Object = 5
NCategories = 3
NPayform_item_per_user = 3

# Other params
Ndays_of_schedule_into_past = 7
Ndays_of_schedule_into_future = 14
Shifts_duration_min_hours = 1
Shifts_duration_max_hours = 3
Payform_item_max_hour = 3

Total_days = Ndays_of_schedule_into_future+Ndays_of_schedule_into_past

# Custom Ratios
Active_notice_chance = 0.7
Public_loc_group_chance = 0.6
User_with_nick_name_chance = 0.3
User_profile_complete_chance = 0.8
User_has_pic_chance = 0.3
Location_has_time_slot_chance = 0.8
Weekday_has_time_slot_chance = 5/7.0
Payform_submitted_chance = 0.9
Payform_printed_chance = 0.5

def progress_bar_gen(title, total)
  progress_bar = ProgressBar.create(title: title, format: '%a %bᗧ%i %p%% %t', progress_mark: ' ', remainder_mark: '･', total: total)
  yield progress_bar
  progress_bar.finish
end

def prompt_field(obj, field)
  puts field.to_s.split('_').collect(&:capitalize).join(' ') + ':'
  obj[field] = STDIN.gets.chomp
  begin
    obj.save!
  rescue ActiveRecord::RecordInvalid => e
    puts e.to_s
    prompt_field(obj, field)
  end
end

def app_config_gen
	ap = AppConfig.new
  ap.auth_types = "CAS"
  ap.footer = 'Certifying authority: Adam Bray, Asst. Manager, Student Technology<br/>Last modified: Wed Feb 28 00:17:00 EST 2007'
  ap.mailer_address = "shifts.app@yale.edu"
  ap.admin_email = Faker::Internet.email
  ap.use_ldap = false
  ap.calendar_feed_hash = SecureRandom.hex(32)
  ap.save!
  ap
end

def user_gen
	user = User.new
	user.first_name = Faker::Name.first_name
	user.last_name = Faker::Name.last_name
  user.nick_name = Faker::Name.first_name if rand() < User_with_nick_name_chance
	user.employee_id = Faker::Number.number(6)
	user.email = Faker::Internet.email(user.name)
	user.auth_type = "CAS"
	begin
        login = user.first_name.downcase.first + user.last_name.downcase.first + Faker::Number.number(2+rand(2))
  end until User.where(login: login).empty?
  user.login = login
  user.set_random_password
  user.departments = [@department]
  user.save!
  user.set_payrate(10+rand(10), @department)
  user
end

def ptaeo_gen
  [7,2,6,6,6].map{|d| Faker::Number.number(d)}.join('.')
end

def loc_group_gen
  begin 
    lgn = Faker::Address.state
  end until LocGroup.where(name: lgn).empty?
  @department.loc_groups.create!(name: lgn)
end

def location_gen(lg = loc_group_gen)
  l = lg.locations.new
  begin
    ln = Faker::Address.city
    sn = ln.first(2).upcase
  end until Location.where(short_name: sn).empty?
  l.name = ln
  l.short_name = sn
  l.min_staff = rand(2)
  l.max_staff = l.min_staff+rand(3)+1
  l.priority = rand(2)
  l.report_email = Faker::Internet.email
  l.category = @category
  l.active = true
  l.description = Faker::Lorem.sentence
  l.save!
  l
end

def user_profile_entry_gen(field, user)
  entry = user.user_profile.user_profile_entries.new
  entry.user_profile_field = field
  entry.content = ""
  if rand()<User_profile_complete_chance
    case field.name
    when "Favorite Word"
      entry.content = Faker::Hacker.noun
    when "About Me"
      entry.content = Faker::Lorem.paragraph
    when "Class"
      entry.content = ["2014","2015","2016","2017","2018","Other"][rand(6)]
    when "Gender"
      entry.content = ["M","F"][rand(2)]
    when "OS"
      entry.content = ["Linux", "OS X","Windows"].sample(1+rand(3)).sort.join(", ")     
    when "Pic"
      entry.content = "http://d24w6bsrhbeh9d.cloudfront.net/photo/aD0OoQK_700b.jpg" if rand()<User_has_pic_chance
    end
  end
  entry.save!
  entry
end

def user_profiles_gen
  # Text field Major
  field1 = @department.user_profile_fields.create!(name: "Favorite Word", display_type: "text_field", public: true, user_editable: true, index_display: true)
  # Paragraph
  field2 = @department.user_profile_fields.create!(name: "About Me", display_type: "text_area", public: true, user_editable: true, index_display: false)
  # Select from List
  field3 = @department.user_profile_fields.create!(name: "Class", display_type: "select", public: true, user_editable: true, index_display: true, values: "2014,2015,2016,2017,2018,Other")
  # Multiple Choice
  field4 = @department.user_profile_fields.create!(name: "Gender", display_type: "radio_button", public: false, user_editable: false, index_display: true, values: "M,F")
  # Check boxes
  field5 = @department.user_profile_fields.create!(name: "OS", display_type: "check_box", public: true, user_editable: true, index_display: false, values: "Linux, OS X, Windows")
  # Picture Link
  field6 = @department.user_profile_fields.create!(name: "Pic", display_type: "picture_link", public: true, user_editable: true, index_display: false)
end

def random_user
  rand_id = rand(User.count)+1
  User.where("id > ?", rand_id).first
end

def announcement_gen(locations=nil)
  a = Announcement.new(indefinite: true, author: @su, department: @department, department_wide: locations.nil?)
  a.start = Faker::Time.backward(5)
  a.content = Faker::Lorem.paragraph
  a.locations = locations if !locations.nil?
  a.save!
  a.remove(@su) if rand() > Active_notice_chance
end

def sticky_gen(locations=nil)
  a = Sticky.new(indefinite: true, author: random_user, department: @department, department_wide: locations.nil?)
  a.start = Faker::Time.backward(5)
  a.content = Faker::Lorem.paragraph
  a.locations = locations if !locations.nil?
  a.save!
  a.remove(random_user) if rand() > Active_notice_chance
end

def link_gen(locations=nil)
  a = Link.new(indefinite: true, author: random_user, department: @department, department_wide: locations.nil?)
  a.start = Faker::Time.backward(5)
  a.content = Faker::Lorem.sentence(2,false,2)
  a.url = Faker::Internet.url
  a.locations = locations if !locations.nil?
  a.save!
  a.remove(@su) if rand() > Active_notice_chance
end

def repeating_time_slots_gen(locations)    
  loc_ids = locations.map(&:id).sort.join(',')
  re = RepeatingEvent.new(calendar: @calendar, is_set_of_timeslots: true)
  re.days_of_week = [1,2,3,4,5,6,7].sample((7*Weekday_has_time_slot_chance).to_i).sort.join(',')
  today = DateTime.now.beginning_of_day
  re.loc_ids = loc_ids
  re.start_time = today+@department_config.schedule_start.minutes
  re.end_time = today+(@department_config.schedule_end-@department_config.time_increment).minutes
  re.start_date = Date.yesterday # Cannot use DateTime! Must use Date!
  re.end_date = Date.today + Total_days.days
  re.save!
  begin
    re.make_future(true)
  rescue Exception => e
    puts
    puts e.message
  end
end

def shift_gen(location, date, user)
  shift = Shift.new(calendar: @calendar, department: @department, location: location, user: user)
  start_hour = @department_config.schedule_start/60
  end_hour = @department_config.schedule_end/60
  shift_start = date + (start_hour+rand(end_hour-start_hour)).hours
  duration = Shifts_duration_min_hours+rand(Shifts_duration_max_hours-Shifts_duration_min_hours)
  shift_end = shift_start + duration.hours
  shift.start = shift_start
  shift.end = shift_end
  shift.power_signed_up = true # to avoid validation trouble
  shift.save!
end

def task_gen(location)
  task = Task.new(location: location)
  task.name = Faker::Lorem.sentence(2,false,2)
  task.kind = ["Hourly", "Daily", "Weekly"].sample
  task.start = Date.today
  task.end = Date.today+Total_days.days
  task.time_of_day = Faker::Time.between(Time.now.beginning_of_day, Time.now.end_of_day, :all)
  task.day_in_week = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].sample
  task.active = true
  task.description = Faker::Lorem.sentence
  task.link = Faker::Internet.url
  task.save!
end

def data_fields_gen(type)
  type.data_fields.create!(name: "How many boxes of paper?", display_type: "text_field", values: "integer", upper_bound: 10.0, lower_bound: 1.0, exact_alert: "0", active: true)
  type.data_fields.create!(name: "Work Notes", display_type: "text_area", active: true)
  type.data_fields.create!(name: "Which college?", display_type: "select", values: "BR, JE, SY, TC, TD, SM, MC, ES, PC, DC, BC, CC", exact_alert: "JE", active: true)
  type.data_fields.create!(name: "Mac or PC?", display_type: "radio_button", values: "Mac, PC", exact_alert: "PC", active: true)
  type.data_fields.create!(name: "Are you happy?", display_type: "check_box", values: "yes, no, dunno", exact_alert: "no", active: true)
end

def data_type_gen
  type = DataType.new(department: @department)
  type.name = Faker::Hacker.noun
  type.description = Faker::Lorem.sentence
  type.save!
  data_fields_gen(type)
  type
end

def data_object_gen(type)
  object = DataObject.new(data_type: type, name: Faker::Lorem.sentence(2,false,1), description: Faker::Hacker.adjective)
  object.locations = Location.all
  object.save!
end

def category_gen
  cat = Category.new(name: Faker::Lorem.sentence(2,false,1), department: @department, billing_code: ptaeo_gen)
  cat.save!
end

def payform_item_gen(payform, cat)
  item = PayformItem.new(category: cat, payform: payform, date: Date.today, source: payform.user.name)
  item.hours = 1 + rand(Payform_item_max_hour)
  item.description = Faker::Hacker.say_something_smart
  item.save!
end

def print_payforms    
  set = PayformSet.new(department: @department)
  set.payforms = @department.payforms.unprinted
  set.payforms.map {|p| p.printed = Time.now}
  set.save!
end

## Beginning of seed script

Timecop.travel(DateTime.now - Ndays_of_schedule_into_past.days)

# First AppConfig
progress_bar_gen("AppConfig [1/9]", 1) do
  @app_config = app_config_gen
end

# Then Department
progress_bar_gen("Department [2/9]", 1) do 
  @department = Department.create!(name: "SDMP")
  @department_config = @department.department_config
  # Setting end-time to 11pm
  @department_config.update_attributes(schedule_end: 1440)
  Category.all.each {|cat| cat.update_attributes(billing_code: ptaeo_gen)}
  @category = @department.categories.first
  @calendar = @department.calendars.default
end

# Create superuser
progress_bar_gen("Superuser [3/9]", 1) do 
  @su = user_gen
  @su.superuser = true
  puts;prompt_field(@su, "login")
  #@su.update_attributes(login: 'xy63')
end

# Creating Locations and Location Groups
progress_bar_gen("Locations [4/9]", NLoc_group*NLocation_per_group) do |bar|
  NLoc_group.times do 
    loc_group = loc_group_gen
    loc_group.update_attributes(public: false) if rand()>Public_loc_group_chance
    NLocation_per_group.times {location_gen(loc_group); bar.increment}
  end
end

# Creating roles
progress_bar_gen("Roles [5/9]", 2) do |bar|
  @ord_role = @department.roles.create!(name: "Developer")
  @ord_role.permissions = LocGroup.all.map{|lg| [lg.view_permission, lg.signup_permission]}.flatten
  bar.increment
  @admin_role = @department.roles.create!(name: "Admin")
  @admin_role.permissions = Permission.all
  @su.roles = Role.all
end

# Creating Users
progress_bar_gen("Users [6/9]", NUser) do |bar|
  NUser.times do 
    user = user_gen
    user.roles << @ord_role
    bar.increment
  end
end

# Creating User Profiles
progress_bar_gen("User Profiles [7/9]", 6*User.count) do |bar|
  user_profiles_gen
  UserProfileField.all.each do |field|
    User.all.each do |user|
      user_profile_entry_gen(field, user)
      bar.increment
    end
  end
end  

# Creating Notices
progress_bar_gen("Notices [8/9]", NNotice_department_wide*2+NAnnouncement+NSticky+NLink) do |bar|
  NNotice_department_wide.times do 
    announcement_gen; bar.increment
    link_gen; bar.increment
  end
  NAnnouncement.times {announcement_gen(Location.all.sample(1+rand(Location.count))); bar.increment}
  NSticky.times {sticky_gen(Location.all.sample(1+rand(Location.count))); bar.increment}
  NLink.times {link_gen(Location.all.sample(1+rand(Location.count))); bar.increment}
end

# Creating Repeating TimeSlots
progress_bar_gen("TimeSlots [9/9]", LocGroup.count) do |bar|
  LocGroup.all.each do |lg|
    n = lg.locations.count
    locs = lg.locations.sample((n*Location_has_time_slot_chance).to_i)
    repeating_time_slots_gen(locs)
    bar.increment
  end
end

# Creating Shifts
nShifts = NShift_per_day_per_location*Total_days*Location.count
progress_bar_gen("Shifts [10/10]", nShifts) do |bar|
  (1..Total_days).each do |d|
    users = User.all.sample(Location.count*NShift_per_day_per_location)
    Location.all.each do |l|
      NShift_per_day_per_location.times do 
        shift_gen(l, Date.today+d.days, users.shift) if !users.empty?
        bar.increment
      end
    end
  end
end

# Creating Tasks
progress_bar_gen("Tasks [11/11]", NTasks_per_location*Location.count) do |bar|
  Location.all.each do |l|
    NTasks_per_location.times do 
      task_gen(l)
      bar.increment
    end
  end
end

# Creating DataObjects
progress_bar_gen("Data Objects [12/12]", NData_Object+1) do |bar|
  type = data_type_gen; bar.increment
  NData_Object.times do 
    data_object_gen(type)
    bar.increment
  end
end

# Creating Categories
progress_bar_gen("Categories [13/13]", NCategories) do |bar|
  NCategories.times do 
    category_gen
    bar.increment
  end
end

# Creating Payforms
progress_bar_gen("Payforms [14/14]", User.count*NPayform_item_per_user) do |bar|
  categories = Category.all
  User.all.each do |user|
    payform = Payform.build(@department, user, Date.today)
    NPayform_item_per_user.times do 
      payform_item_gen(payform, categories.sample)
      bar.increment
    end
    if rand()<Payform_submitted_chance and user!=@su
      payform.update_attributes(submitted: Time.now)
      if rand()<Payform_printed_chance
        payform.update_attributes(approved: Time.now, approved_by: @su)
      end
    end
  end
  print_payforms
end


Timecop.return

