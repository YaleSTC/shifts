namespace :shifts do
  task (:import_kilroys => :environment) do
    kilroys = "Farrah Kahn,1,SW
David Hu,3,SW
Machiste Quintana,5,SW
Yuan Kang,7,SW
Rachel Kurchin,2,SCL
Abby Hu,4,SCL
Alan Elbaum,5,SCL
Farrah Kahn,6,SCL
Derrik Petrin,2,HGS
Raph Leung,3,HGS
Nat Harrington,4,HGS
Tasia Smith,5,HGS
Derrik Petrin,6,HGS
Toshihiko Shimasaki,1,HHH
Toshihiko Shimasaki,2,HHH
Toshihiko Shimasaki,3,HHH
Toshihiko Shimasaki,4,HHH
Toshihiko Shimasaki,5,HHH
Toshihiko Shimasaki,6,HHH
Toshihiko Shimasaki,7,HHH
Erin Maher,2,PR276
Nick Wang,3,PR276
Nick Wang,5,PR276
Erin Maher,6,PR276"

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
      	a.start_time = Time.parse("2011-10-10 07:00:00")
      	a.end_time = Time.parse("2011-10-10 07:30:00")
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