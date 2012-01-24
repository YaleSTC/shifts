namespace :shifts do
  task (:import_kilroys => :environment) do
    kilroys = "Aayush Upadhyay,1,BR
Abby Reisner,3,CC
Abby Hu,5,TD
Abby Hu,7,TD
Adam McIlravey,7,ES
Alan Elbaum,3,PC
Alexandra Slade,2,PC
Ali Zia,4,MC
Andrew Zaragoza,1,CC
Andrew Kim,1,TC
Anthony Hsu,4,BK
Ayesha Muhammad,2,JE
Ben Green,5,PC
Bob Qu,5,JE
Brandon Blaesser,6,CC
Brian Mwiti,6,RH
Carolina Trombetta,1,ES
Chen Wang,6,TC
Chris Zheng,3,DC
Chris Bradshaw,7,JE
Chris Vasseur,3,JE
Connor Moseley,2,BK
Cyril Zhang,3,SM
Daniel Ribas,5,ES
Danqing Liu,6,ES
David Yin,3,BK
David Bett,2,CC
David Goerger,2,TD
David Goerger,6,TD
David Hu,6,ES
Derrik Petrin,5,ES
Devon Balicki,2,SY
Eddie Chen,5,RH
Eddie Chen,7,RH
Ellen Su,1,RH
Ellen Su,3,RH
Eric Pan,5,PC
Erin Maher,2,SM
Farrah Khan,1,BK
Frank Teng,3,MC
Gia Lomsadze,1,DC
Gloria Ma,6,SM
Harry Yu,6,SY
Hengchu Zhang,4,CC
Henry Lukoma,2,RH
Henry Davidge,4,SM
Hobart Lim,7,BK
Hugh O'Cinneide,5,CC
Ian Suvak,3,MC
Irene Cai,2,MC
Jakub Kowalik,1,TD
Jakub Kowalik,4,TD
James Luo,5,SY
Jan Kolmas,2,TC
Jason Mazzella,2,ES
Jason Parisi,7,PC
Jian Li,5,DC
Jim Liu,5,BR
Jimi Mandilk,5,SY
John Pham,4,MC
Josh Rozner,6,JE
Josh Fuller,3,BR
Kartik Venkatraman,6,SY
Kwang Liang Chew,6,BR
Kwang Liang Chew,7,BR
Larry Huynh,6,BK
Laura Wellman,1,DC
Lucas Pratt,5,DC
Machiste Quintana,2,SM
Marc Lozano,5,SM
Margaret Yim,4,TC
Mason Liang,6,PC
Matthew Everts,2,PC
Matthew Ribeiro,1,PC
Max Cho,3,SY
Max Jacobson,2,SY
Mike Jin,4,ES
Minami Funakoshi,1,SY
Misbah Uraizee,1,SM
Nat Harrington,5,BK
Nick Wang,4,SY
Nnamdi Iregbulem,7,DC
Pat Toth,1,MC
Paul Rutland,4,RH
Peter Xu,6,MC
Peter Tian,7,SY
Rachel Kurchin,4,PC
Raph Leung,2,TC
Richard Chang,6,MC
Rick Caraballo,7,SY
Sam Anklesaria,3,ES
Sharon Yin,6,DC
Shehzeen Kamil,3,TC
Sherwin Yu,5,MC
Shunori Ramanathan,3,SY
Sijia Song,2,DC
Sikander Khan,4,DC
Simon Podhajsky,5,BK
Sirui Sun,2,BR
Sirui Sun,4,BR
Smith Shah,7,CC
Tammer Abiyu,1,SY
Tasia Smith,1,PC
Teshika Jayewickreme,4,SM
Thomas Rokholt,7,SM
Thomas Weng,5,TC
TJ Park,4,JE
Usman Anwer,3,TD
Victor Zhao,7,MC
Victor Kang,7,TC
Wei Yan,1,JE
Wonyong Chung,5,SM
Yuan Kang,4,ES
Zachary Maher,4,SY
Zack Reneau-Wedeen,1,TC"

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