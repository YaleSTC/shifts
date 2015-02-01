# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Daley', city: cities.first)

require 'faker'

# Number of records
NLoc_group = 2
NLocation_per_group = 3
NUser = 10
NAnnouncement = 6
NSticky = 10
NLink = 10
NNotice_department_wide = 1

# Custom Ratios
Active_user_chance = 0.6 # Not implemented
Active_loc_group_chance = 0.8 # Not implemented
Active_location_chance = 0.8 # Not implemented
Active_notice_chance = 0.7
Public_loc_group_chance = 0.6
User_with_nick_name_chance = 0.2
User_profile_complete_chance = 0.8
User_has_profile_chance = 0.3

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
  l.min_staff = rand(3)
  l.max_staff = l.min_staff+rand(3)
  l.priority = rand(10)
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
    when "Favorite Meme"
      entry.content = "http://d24w6bsrhbeh9d.cloudfront.net/photo/aD0OoQK_700b.jpg" if rand()<User_has_profile_chance
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

  UserProfileField.all.each do |field|
    User.all.each do |user|
      user_profile_entry_gen(field, user)
    end
  end  
end

def random_user
  rand_id = rand(User.count)+1
  User.where("id > ?", rand_id).first
end

def announcement_gen(locations=nil)
  a = Announcement.new(indefinite: true, author: @su, department: @department, department_wide: locations.nil?)
  a.start = Faker::Time.backward(14)
  a.content = Faker::Lorem.paragraph
  a.locations = locations if !locations.nil?
  a.save!
  a.remove(@su) if rand() > Active_notice_chance
end

def sticky_gen(locations=nil)
  a = Sticky.new(indefinite: true, author: random_user, department: @department, department_wide: locations.nil?)
  a.start = Faker::Time.backward(14)
  a.content = Faker::Lorem.paragraph
  a.locations = locations if !locations.nil?
  a.save!
  a.remove(random_user) if rand() > Active_notice_chance
end

def link_gen(locations=nil)
  a = Link.new(indefinite: true, author: random_user, department: @department, department_wide: locations.nil?)
  a.start = Faker::Time.backward(14)
  a.content = Faker::Lorem.sentence(2,false,2)
  a.url = Faker::Internet.url
  a.locations = locations if !locations.nil?
  a.save!
  a.remove(@su) if rand() > Active_notice_chance
end

# First AppConfig
puts "creating AppConfig..."
@app_config = app_config_gen

# Then Department
puts "creating Department.."
@department = Department.create!(name: "SDMP")
@department_config = @department.department_config
# Setting end-time to 11pm
@department_config.update_attributes(schedule_end: 1440)
@category = @department.categories.first
@category.update_attributes(billing_code: ptaeo_gen)
@calendar = @department.calendars.default

# Create superuser
puts "creating Superuser..."
@su = user_gen
@su.superuser = true
#prompt_field(@su, "login")
@su.update_attributes(login: 'xy63')

# Creating Locations and Location Groups
puts "creating loc_groups and locations..."
NLoc_group.times do 
  loc_group = loc_group_gen
  loc_group.update_attributes(public: false) if rand()>Public_loc_group_chance
  NLocation_per_group.times { location_gen(loc_group) }
end

# Creating roles
puts "creating roles..."
@ord_role = @department.roles.create!(name: "Developer")
@admin_role = @department.roles.create!(name: "Admin")
@ord_role.permissions = LocGroup.all.map{|lg| [lg.view_permission, lg.signup_permission]}.flatten
@admin_role.permissions = Permission.all
@su.roles = Role.all

# Creating Users
puts "creating users..."
NUser.times do 
  user = user_gen
  user.roles << @ord_role
end

# Creating User Profiles
puts "creating user profiles..."
user_profiles_gen

# Creating Notices
puts "creating notices..."
NNotice_department_wide.times do 
  announcement_gen
  link_gen
end
NAnnouncement.times {announcement_gen(Location.all.sample(1+rand(Location.count)))}
NSticky.times {sticky_gen(Location.all.sample(1+rand(Location.count)))}
NLink.times {link_gen(Location.all.sample(1+rand(Location.count)))}


## Locations and Loc_grous and users are deactivated after the setup



