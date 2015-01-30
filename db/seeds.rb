# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Daley', city: cities.first)

require 'faker'


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
    ap.calendar_feed_hash = Faker::Lorem.characters(64)
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
        user.login = user.first_name.downcase.first + user.last_name.downcase.first + Faker::Number.number(2+rand(2))
    end while (User.all.collect(&:login).include? user.login)
    user.set_random_password
    user.departments = [@department]
    user
end


# First AppConfig
@app_config = app_config_gen
@app_config.save
# Then Department
@department = Department.create(name: "SDMP")
@category = @department.categories.first
@calendar = @department.calendars.default
# Then create superuser
@su = user_gen
@su.superuser = true
prompt_field(@su, "login")
