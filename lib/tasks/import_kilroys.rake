namespace :shifts do
  task (:import_kilroys => :environment) do
    kilroys = "Farrah Khan,1,SW
Farrah Khan,6,SCL
"

    message = ""


    kilroys.split("\n").each do |kilroy|
      kilroy = kilroy.split(",")
      location = Location.find_by_short_name(kilroy[2])
      user = User.search(kilroy[0])
      day = kilroy[1]
      day = 0 if day == 7
      if user == nil
      	message += "#{kilroy[0]} in #{kilroy[2]} on day #{kilroy[1]} wasn't added.\n"
      else	
      	a = RepeatingEvent.new
      	a.start_date = Time.parse("2012-01-25 00:00:00").utc
      	a.end_date = Time.parse("2012-05-20 00:00:00").utc
      	a.start_time = Time.parse("2011-10-10 06:00:00")
      	a.end_time = Time.parse("2011-10-10 06:30:00")
      	a.calendar_id = 1
      	a.user_id = user.id
      	a.loc_ids = "#{location.id}"
      	a.days_of_week = "#{day}"
      	a.is_set_of_timeslots = false
      	a.save
      	a.make_future(true)
      end
    end
    print message
  end
end