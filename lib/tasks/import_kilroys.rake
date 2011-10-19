namespace :shifts do
  task (:import_kilroys => :environment) do
    kilroys = "Casey Watts,3,BK
Josh Rozner,3,BR
Alex Fayette,3,CC
Chris Zheng,3,DC
Yuan Kang,3,ES
Wei Yan,3,JE
Ali Zia,3,MC
Tasia Smith,3,PC
Shinori Ramanathan,3,SY
Jonah Quinn,3,SM
Eddie Chen,3,TD
Jan Kolmas,3,TC
Jared Bard,4,BK
Brian Odhiambo,4,BR
Caroline Jaffe,4,CC
Sikander Khan,4,DC
Mike Jin,4,ES
Pat Toth,4,JE
Peter Xu,4,MC
Rachel Kurchin,4,PC
Zach Maher,4,SY
Jared Shenson,4,SM
Ellen Su,4,TD
Andrew Kim,4,TC
Nat Harrington,2,BK
Sirui Sun,2,BR
Michael Giuffrida,2,CC
Laura Wellman,2,DC
David Hu,2,ES
Bob Qu,2,JE
Frank Teng,2,MC
Matt Everts,2,PC
Max Cho,2,SY
Nick Maas,2,SY
Wonyong Chung,2,SM
Henry Lukoma,2,TD
Jan Kolmas,2,TC
Anthony Hsu,5,BK
Tim Xu,5,BR
Nick Wang,5,CC
Jian Li,5,DC
Derrik Petrin,5,ES
David Yu,5,JE
Irene Cai,5,MC
Ben Green,5,PC
Minami Funakoshi,5,SY
Peter Tian,5,SY
Machiste Quintana,5,SM
Paul Rutland,5,TD
Margaret Yim,5,TC
Anthony Hsu,6,BK
Ben Silver,6,BR
Dan Liu,6,CC
Sijia Song,6,DC
Sean Haufler,6,JE
Sherwin Yu,6,MC
Mu Li,6,PC
Kartik Venkatraman,6,SY
Wonyong Chung,6,SM
Brian Mwiti,6,TD
Matt Griffith,6,TC"

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