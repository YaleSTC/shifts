# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Daley', city: cities.first)

require 'faker'

NLoc_group = 5
NLocation_per_group = 10
Active_loc_group_chance = 0.8
Active_location_chance = 0.8
Public_loc_group_chance = 0.6

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
  ap
end

def user_gen
	user = User.new
	user.first_name = Faker::Name.first_name
	user.last_name = Faker::Name.last_name
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
  @department.loc_groups.create(name: lgn);
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

# First AppConfig
puts "creating AppConfig..."
@app_config = app_config_gen
@app_config.save!

# Then Department
puts "creating Department.."
@department = Department.create(name: "SDMP")
@department_config = @department.department_config
# Setting end-time to 11pm
@department_config.update_attributes(schedule_end: 1380)
@category = @department.categories.first
@category.billing_code = ptaeo_gen
@calendar = @department.calendars.default

# Create superuser
puts "creating Superuser..."
@su = user_gen
@su.superuser = true
prompt_field(@su, "login")

# Creating Locations and Location Groups
puts "creating loc_groups and locations..."
NLoc_group.times do 
  loc_group = loc_group_gen
  loc_group.public = false if rand()>Public_loc_group_chance
  NLocation_per_group.times { location_gen(loc_group) }
end

# Creating roles
puts "creating roles..."
@ord_role = @department.roles.create(name: "Developer")
@admin_role = @department.roles.create(name: "Admin")
@ord_role.permissions = LocGroup.all.map{|lg| [lg.view_permission, lg.signup_permission]}.flatten
@admin_role.permissions = Permission.all
@su.roles = Role.all

## Locations and Loc_grousp are deactivated after the setup of shifts



