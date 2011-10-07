namespace :shifts do
  task (:import_kilroys => :environment) do
    kilroys = "Anthony Hsu,6,BK
    Ben Silver,6,BR
    Dan Liu,6,CC
    Sijia Song,6,DC
    Anthony Hsu,6,ES
    Sean Haufler,6,JE
    Sherwin Yu,6,MC
    Mu Li,6,PC
    Kartik Ventrakaman,6,SY
    Wonyong Chung,6,SM
    Brian Mwiti,6,TD
    Matt Griffith,6,TC
    Hobart Lim,7,BK
    Ayesha Muhammad,7,BR
    Dan Liu,7,CC
    Nnamdi Irregbulem,7,DC
    Maria Altyeva,7,ES
    Victor Zhao,7,MC
    Mu Li,7,PC
    Harry Yu,7,SY
    Ray Xiong,7,SM
    Ellen Su,7,TD
    Victor Kang,7,TC
    Sharon Ji,1,BR
    Michael Giuffrida,1,CC
    Lucas Pratt,1,DC
    Maria Altyeva,1,ES
    Tiffany Pang,1,JE
    Pat Toth,1,MC
    Tasia Smith,1,PC
    Rick Caraballo,1,SY
    James Luo,1,SY
    Machiste Quintana,1,SM
    Usman Anwer,1,TD
    Andrew Kim,1,TC
    Tony Wu,1,TC"

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