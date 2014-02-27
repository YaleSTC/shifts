namespace :db do
  desc "Making user id=1 the superuser"

  task :superuser => :environment do
    STDOUT.sync=true
    print "First Name? >"
    first = STDIN.gets.chomp
    print "Last Name? >"
    last = STDIN.gets.chomp
    print "netid? >"
    netid = STDIN.gets.chomp
    print "email? >"
    email = STDIN.gets.chomp
    puts "renaming user name, email and netid (login)"
    
    me=User.find(1)
    me.first_name=first
    me.last_name=last
    me.login=netid
    me.email=email
    me.rank='Admiral'
    me.supermode = true
    me.superuser = true
    if !me.save
      puts "Unable to Save! The error message:"
      me.errors.full_messages.each do |message|
        puts message
      end
    end
  end
end

