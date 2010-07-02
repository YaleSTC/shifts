class StickiesController < NoticesController

  def index
		redirect_to(notices_path)
  end

  def show
     redirect_to(notices_path)
  end

  def new
    @sticky = Sticky.new
		@current_shift_location = current_user.current_shift.location if current_user.current_shift
    layout_check
  end

  def create
    @sticky = Sticky.new(params[:sticky])
		set_author_dept_and_times
		begin
      Sticky.transaction do
        @sticky.save(false)
        set_sources(@sticky)
        @sticky.save!
    	end
		rescue Exception
      respond_to do |format|
        format.html { render :action => "new" }
        format.js  #create.js.rjs
      end
    else
      respond_to do |format|
        format.html {
        flash[:sticky] = 'Sticky was successfully created.'
        redirect_to stickies_path
        }
        format.js  #create.js.rjs
      end
    end
  end

	def update
    @sticky = Sticky.find_by_id(params[:id]) || Sticky.new
    @sticky.update_attributes(params[:sticky])
		set_author_dept_and_times
    begin
      Sticky.transaction do
        @sticky.save(false)
        set_sources(@sticky)
        @sticky.save!
      end
    rescue Exception
        respond_to do |format|
          format.html { render :action => "new" }
        end
      else
        respond_to do |format|
        format.html {
          flash[:notice] = 'Sticky was successfully created.'
          redirect_to :action => "index"
        }
      end
    end
  end

  def destroy
		redirect_to :controller => 'notice', :action => 'destroy'
	end

	private
	def set_author_dept_and_times
		@sticky.author = current_user
		@sticky.department = current_department
		@sticky.start_time = Time.now
		if params[:end_time_choice] == "indefinite"
			@sticky.end_time = nil
			@sticky.indefinite = true
		elsif params[:sticky][:end_time] == "day"
			@sticky.end_time = 1.day.from_now
		elsif params[:sticky][:end_time] == "week"
			@sticky.end_time = 1.week.from_now
		elsif params[:sticky][:end_time] == "month"
			@sticky.end_time = 1.month.from_now
		end
	end
end
