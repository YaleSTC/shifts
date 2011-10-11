namespace :shifts do
  task (:import_kilroys => :environment) do
    kilroys = "Casey Watts,2,BK
Josh Rozner,2,BR
Alex Fayette,2,CC
Chris Zheng,2,DC
Yuan Kang,2,ES
Wei Yan,2,JE
Ali Zia,2,MC
Tasia Smith,2,PC
Shinori Ramanathan,2,SY
Jonah Quinn,2,SM
Eddie Chen,2,TD
Jan Kolmas,2,TC
Jared Bard,3,BK
Brian Odhiambo,3,BR
Caroline Jaffe,3,CC
Sikander Khan,3,DC
Mike Jin,3,ES
Pat Toth,3,JE
Peter Xu,3,MC
Rachel Kurchin,3,PC
Zach Maher,3,SY
Jared Shenson,3,SM
Ellen Su,3,TD
Andrew Kim,3,TC"

    message = ""


    kilroys.split("\n").each do |kilroy|
      kilroy = kilroy.split(",")
      location = Location.find_by_short_name(kilroy[2])
      user = User.search(kilroy[0])
      day = kilroy[1]
      day = 0 if day == 7
      if user == nil
      	message += "#{kilroy[0]} wasn't added.\n"
      else	
      	a = RepeatingEvent.new
      	a.start_date = Time.now.midnight.utc
      	a.end_date = Time.parse("2011-12-18 00:00:00").utc
      	a.start_time = Time.parse("2011-10-10 01:00:00")
      	a.end_time = Time.parse("2011-10-10 02:00:00")
      	a.calendar_id = 1
      	a.user_id = user.id
      	a.loc_ids = "#{location.id}"
      	a.days_of_week = "#{day}"
      	a.is_set_of_timeslots = false
      	a.save
      	a.make_future(true)
      end
    end
  end
end