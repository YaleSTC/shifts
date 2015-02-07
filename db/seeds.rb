# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Daley', city: cities.first)

require 'faker'
require 'ruby-progressbar'
################################################################################
## Parameters
################################################################################
# Number of records
N_LOC_GROUPS = 3
N_LOCATIONS_PER_GROUP = 3
N_USERS = 50
N_ANNOUNCEMENTS = 6
N_STICKIES = 10
N_LINKS = 10
N_DEPARTMENT_WIDE_NOTICES = 1
N_SHIFTS_PER_DAY_PER_LOCATION = 3
N_TASKS_PER_LOCATION = 5
N_DATA_OBJECTS = 5
N_CATEGORIES = 3
N_PAYFORM_ITEMS_PER_USER = 3
N_REPORT_ITEMS_PER_REPORT = 8

# Other params
N_DAYS_OF_SCHEDULE_INTO_PAST = 7
N_DAYS_OF_SCHEDULE_INTO_FUTURE = 14
SHIFTS_DURATION_MIN_HOURS = 1
SHIFTS_DURATION_MAX_HOURS = 3
PAYFORM_ITEM_MAX_HOUR = 3

TOTAL_DAYS = N_DAYS_OF_SCHEDULE_INTO_FUTURE+N_DAYS_OF_SCHEDULE_INTO_PAST

# Custom Ratios
ACTIVE_NOTICE_CHANCE = 0.8
PUBLIC_LOC_GROUP_CHANCE = 0.6
USER_WITH_NICK_NAME_CHANCE = 0.3
USER_PROFILE_COMPLETE_CHANCE = 0.9
USER_HAS_PIC_CHANCE = 0.4
LOCATION_HAS_TIME_SLOT_CHANCE = 0.8
WEEKDAY_HAS_TIME_SLOT_CHANCE = 5/7.0
SHIFT_SIGNED_IN_CHANCE = 0.9
SHIFT_SUBBED_CHANCE = 0.1
PAYFORM_SUBMITTED_CHANCE = 0.9
PAYFORM_PRINTED_CHANCE = 0.7
################################################################################
## Helper methods
################################################################################
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

def ptaeo_gen
  [7,2,6,6,6].map{|d| Faker::Number.number(d)}.join('.')
end

def random_user
  rand_id = rand(User.count)+1
  User.where("id > ?", rand_id).first
end
################################################################################
## Record Generating Methods
################################################################################
def app_config_gen
  ap = AppConfig.new
  ap.auth_types = "CAS"
  ap.footer = 'Seed Script by David Yao'
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
  user.nick_name = Faker::Name.first_name if rand() < USER_WITH_NICK_NAME_CHANCE
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
  if rand()<USER_PROFILE_COMPLETE_CHANCE
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
      entry.content = "http://d24w6bsrhbeh9d.cloudfront.net/photo/aD0OoQK_700b.jpg" if rand()<USER_HAS_PIC_CHANCE
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

def announcement_gen(locations=nil)
  a = Announcement.new(indefinite: true, author: @su, department: @department, department_wide: locations.nil?)
  a.start = Faker::Time.backward(5)
  a.content = Faker::Lorem.paragraph
  a.locations = locations if !locations.nil?
  a.save!
  a.remove(@su) if rand() > ACTIVE_NOTICE_CHANCE
end

def sticky_gen(locations=nil)
  a = Sticky.new(indefinite: true, author: random_user, department: @department, department_wide: locations.nil?)
  a.start = Faker::Time.backward(5)
  a.content = Faker::Lorem.paragraph
  a.locations = locations if !locations.nil?
  a.save!
  a.remove(random_user) if rand() > ACTIVE_NOTICE_CHANCE
end

def link_gen(locations=nil)
  a = Link.new(indefinite: true, author: random_user, department: @department, department_wide: locations.nil?)
  a.start = Faker::Time.backward(5)
  a.content = Faker::Company.name
  a.url = Faker::Internet.url
  a.locations = locations if !locations.nil?
  a.save!
  a.remove(@su) if rand() > ACTIVE_NOTICE_CHANCE
end

def repeating_time_slots_gen(locations)    
  loc_ids = locations.map(&:id).sort.join(',')
  re = RepeatingEvent.new(calendar: @calendar, is_set_of_timeslots: true)
  re.days_of_week = [1,2,3,4,5,6,7].sample((7*WEEKDAY_HAS_TIME_SLOT_CHANCE).to_i).sort.join(',')
  today = DateTime.now.beginning_of_day
  re.loc_ids = loc_ids
  re.start_time = today+@department_config.schedule_start.minutes
  re.end_time = today+(@department_config.schedule_end-@department_config.time_increment).minutes
  re.start_date = Date.yesterday # Cannot use DateTime! Must use Date!
  re.end_date = Date.today + (TOTAL_DAYS*2).days
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
  duration = SHIFTS_DURATION_MIN_HOURS+rand(SHIFTS_DURATION_MAX_HOURS-SHIFTS_DURATION_MIN_HOURS+1)
  shift_end = shift_start + duration.hours
  shift.start = shift_start
  shift.end = shift_end
  shift.power_signed_up = true # to avoid validation trouble
  shift.save!
end

def task_gen(location)
  task = Task.new(location: location)
  begin
    task.name = Faker::Hacker.verb + Faker::Hacker.adjective + Faker::Hacker.noun
  end until Task.where(name: task.name).empty?
  task.kind = ["Hourly", "Daily", "Weekly"].sample
  task.start = Date.today
  task.end = Date.today+TOTAL_DAYS.days
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
  object = DataObject.new(data_type: type, description: Faker::Company.catch_phrase)
  begin
    object.name = Faker::App.name + Faker::App.version
  end until DataObject.where(name: object.name).empty?
  object.locations = Location.all
  object.save!
end

def category_gen
  cat = Category.new(name: Faker::Name.title, department: @department, billing_code: ptaeo_gen)
  cat.save!
end

def payform_item_gen(payform, cat)
  item = PayformItem.new(category: cat, payform: payform, date: Date.today, source: payform.user.name)
  item.hours = 1 + rand(PAYFORM_ITEM_MAX_HOUR)
  item.description = Faker::Hacker.say_something_smart
  item.save!
end

def print_payforms    
  set = PayformSet.new(department: @department)
  set.payforms = @department.payforms.unprinted
  set.payforms.map {|p| p.printed = Time.now}
  set.save!
end

def report_item_gen(report, ip)
  report.report_items.create!(time: Time.now, content: Faker::Hacker.say_something_smart, ip_address: ip)
end

def report_gen(shift)
  report = Report.new(shift: shift, arrived: shift.start)
  report.save!
  ip = Faker::Internet.ip_v4_address
  N_REPORT_ITEMS_PER_REPORT.times do 
    report_item_gen(report, ip)
  end
  report.update_attributes(departed: shift.end)
end

def sub_request_gen(shift)
  sub = SubRequest.new(shift: shift, reason: Faker::Lorem.sentence)
  slots = ((shift.end - shift.start)/3600).to_i
  mand_end_slot = 1+rand(slots)
  end_slot = mand_end_slot+rand(slots-mand_end_slot+1)
  sub.mandatory_start = shift.start
  sub.mandatory_end = shift.start+mand_end_slot*1.hour
  sub.start = shift.start
  sub.end = shift.start+end_slot*1.hour
  sub.save!
end
################################################################################
## Beginning of seed script
################################################################################
Timecop.travel(DateTime.now - N_DAYS_OF_SCHEDULE_INTO_PAST.days)

# First AppConfig
progress_bar_gen("AppConfig [1/16]", 1) do
  @app_config = app_config_gen
end

# Then Department
progress_bar_gen("Department [2/16]", 1) do 
  @department = Department.create!(name: "SDMP")
  @department_config = @department.department_config
  # Setting end-time to 11pm
  @department_config.update_attributes(schedule_end: 1440)
  Category.all.each {|cat| cat.update_attributes(billing_code: ptaeo_gen)}
  @category = @department.categories.first
  @calendar = @department.calendars.default
end

# Create superuser
progress_bar_gen("Superuser [3/16]", 1) do 
  @su = user_gen
  @su.superuser = true
  puts;prompt_field(@su, "login")
end

# Creating Locations and Location Groups
progress_bar_gen("Locations [4/16]", N_LOC_GROUPS*N_LOCATIONS_PER_GROUP) do |bar|
  N_LOC_GROUPS.times do 
    loc_group = loc_group_gen
    loc_group.update_attributes(public: false) if rand()>PUBLIC_LOC_GROUP_CHANCE
    N_LOCATIONS_PER_GROUP.times {location_gen(loc_group); bar.increment}
  end
end

# Creating roles
progress_bar_gen("Roles [5/16]", 2) do |bar|
  @ord_role = @department.roles.create!(name: "Developer")
  @ord_role.permissions = LocGroup.all.map{|lg| [lg.view_permission, lg.signup_permission]}.flatten
  bar.increment
  @admin_role = @department.roles.create!(name: "Admin")
  @admin_role.permissions = Permission.all
  @su.roles = Role.all
end

# Creating Users
progress_bar_gen("Users [6/16]", N_USERS) do |bar|
  N_USERS.times do 
    user = user_gen
    user.roles << @ord_role
    bar.increment
  end
end

# Creating User Profiles
progress_bar_gen("User Profiles [7/16]", 6*User.count) do |bar|
  user_profiles_gen
  UserProfileField.all.each do |field|
    User.all.each do |user|
      user_profile_entry_gen(field, user)
      bar.increment
    end
  end
end  

# Creating Notices
progress_bar_gen("Notices [8/16]", N_DEPARTMENT_WIDE_NOTICES*2+N_ANNOUNCEMENTS+N_STICKIES+N_LINKS) do |bar|
  N_DEPARTMENT_WIDE_NOTICES.times do 
    announcement_gen; bar.increment
    link_gen; bar.increment
  end
  N_ANNOUNCEMENTS.times {announcement_gen(Location.all.sample(1+rand(Location.count))); bar.increment}
  N_STICKIES.times {sticky_gen(Location.all.sample(1+rand(Location.count))); bar.increment}
  N_LINKS.times {link_gen(Location.all.sample(1+rand(Location.count))); bar.increment}
end

# Creating Repeating TimeSlots
progress_bar_gen("TimeSlots [9/16]", LocGroup.count) do |bar|
  LocGroup.all.each do |lg|
    n = lg.locations.count
    locs = lg.locations.sample((n*LOCATION_HAS_TIME_SLOT_CHANCE).to_i)
    repeating_time_slots_gen(locs)
    bar.increment
  end
end

# Creating Shifts
nShifts = N_SHIFTS_PER_DAY_PER_LOCATION*TOTAL_DAYS*Location.count
progress_bar_gen("Shifts [10/16]", nShifts) do |bar|
  (1..TOTAL_DAYS).each do |d|
    users = User.all.sample(Location.count*N_SHIFTS_PER_DAY_PER_LOCATION)
    Location.all.each do |l|
      N_SHIFTS_PER_DAY_PER_LOCATION.times do 
        shift_gen(l, Date.today+d.days, users.shift) if !users.empty?
        bar.increment
      end
    end
  end
end

# Creating Tasks
progress_bar_gen("Tasks [11/16]", N_TASKS_PER_LOCATION*Location.count) do |bar|
  Location.all.each do |l|
    N_TASKS_PER_LOCATION.times do 
      task_gen(l)
      bar.increment
    end
  end
end

# Creating DataObjects
progress_bar_gen("Data Objects [12/16]", N_DATA_OBJECTS+1) do |bar|
  type = data_type_gen; bar.increment
  N_DATA_OBJECTS.times do 
    data_object_gen(type)
    bar.increment
  end
end

# Creating Shift Reports
shifts = Shift.where("end < ?", Time.now+N_DAYS_OF_SCHEDULE_INTO_PAST.days)
progress_bar_gen("Shift Reports [13/16]", shifts.count) do |bar|
  shifts.each do |shift|
    report_gen(shift) if rand()<SHIFT_SIGNED_IN_CHANCE 
    bar.increment
  end
end

# Creating SubRequests
shifts = Shift.where("start > ?", Time.now+N_DAYS_OF_SCHEDULE_INTO_PAST.days)
progress_bar_gen("SubRequests [14/16]", shifts.count) do |bar|
  shifts.each do |shift|
    sub_request_gen(shift) if rand()<SHIFT_SUBBED_CHANCE
    bar.increment
  end
end

# Creating Categories
progress_bar_gen("Categories [15/16]", N_CATEGORIES) do |bar|
  N_CATEGORIES.times do 
    category_gen
    bar.increment
  end
end

# Creating Payforms
progress_bar_gen("Payforms [16/16]", User.count*N_PAYFORM_ITEMS_PER_USER) do |bar|
  categories = Category.all
  User.all.each do |user|
    payform = Payform.build(@department, user, Date.today)
    N_PAYFORM_ITEMS_PER_USER.times do 
      payform_item_gen(payform, categories.sample)
      bar.increment
    end
    if rand()<PAYFORM_SUBMITTED_CHANCE && user!=@su
      payform.update_attributes(submitted: Time.now)
      if rand()<PAYFORM_PRINTED_CHANCE
        payform.update_attributes(approved: Time.now, approved_by: @su)
      end
    end
  end
  print_payforms
end

Timecop.return
################################################################################
