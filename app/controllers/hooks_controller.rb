#Allow RT to bill job.  Scenarios to handle:
#1. user is not logged into Shift, so should take him to log in and bill -- login must match RT login
#2. user is logged into Shift and is different user from RT -- display error on Shift main page (dashboard)
#3. user is logged into Shift, same netid as from RT, but with invalid parameters -- display error on Shift main page (dashboard)
#4. same users and valid parameters -- perform billing and redirect back to RT

#  RT sends sth like this:
#  http://APP_URL/hooks/add_job?
#  url=http://uhu.its.yale.edu/Ticket/Display.html?id=26003
#  &date=2009-09-20
#  &category=1
#  &total=0.0833333333333333
#  &creator=RT
#  &comments=Ticket_12345:_[Kayne]%20Yo%20Imgonna%20letyoufinish
#  &netid=dtt22

# Test URL: http://APP_URL/rt?url=http://uhu.its.yale.edu/Ticket/Display.html?id=12345&date=2009-09-20&category=1&total=0.0833333333333333&creator=RT&comments=Ticket_12345:_[Kayne]%20Yo%20Immagonna%20letyoufinish&netid=dtt22

class HooksController < ApplicationController
  # skip all before filters to add_job
  skip_filter filter_chain, :only => 'add_job'

  # this method hides the billing params from URL when you redirected to CAS
  # so that people are less tempted to mess around
  def add_job
    session[:external] = params.clone

    session[:external][:ip] = request.remote_ip

    redirect_to :action => :add_job_after
  end

  def add_job_after
    p = session[:external]
    unless p.blank?
      #if currently logged in user of RT and Payform are different
      if current_user.login != p[:netid]
        #if RT is actually sending a valid netid
        if (rt_user = User.find_by_login p[:netid])
          flash[:big_notice] = "ALERT: Payform is not billing for #{rt_user.name} \
                               because #{current_user.name} is logged in. \
                               Please log #{current_user.name} out of Payform and try billing again from RT."
        else
          flash[:error] = "Please report to Admin. ERROR: Invalid user"
        end

      # if user is matched
      elsif p[:total] && p[:comments] && p[:date]
        #only bill to STC
        if (dept = Department.find_by_name "STC")
          @payform_item = PayformItem.new(:hours => p[:total].to_f,
                                          :description => p[:comments],
                                          :category => Category.find_by_name("RT"),
                                          :payform => Payform.build(dept, current_user, Time.now),
                                          :source_url => p[:url],
                                          :date => Date.today)

          if @payform_item.save
            flash[:notice] = "Successfully updated payform."
            if p[:url]
              # SUCCESS!!!
              session[:external] = nil
              redirect_to p[:url] and return
            end
          else
            flash[:error] = "Please report to Admin.  ERROR: Could not save to payform."
          end
        else
          flash[:error] = "Please report to Admin. ERROR: Department not found."
        end
      else
        flash[:error] = "Please report to Admin. ERROR: Invalid Params."
      end

      # FAIL
      # log tampering attemps
      logger.info("**Billing failed** IP #{p[:ip]} sends this to hooks/add_job: #{p.to_json}")
      # clear relevant session detail
      session[:external] = nil
    else
      logger.info("**Billing failed** add_job_after called with session[:external] empty.")
    end

    redirect_to(root_path)
  end
end

