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
		@display = params[:on_report_view] == "true" ? "none" : "inline"
    layout_check
  end

  def create
    @sticky = Sticky.new(params[:sticky])
		set_author_dept_and_times
		current_user.current_shift ? @in_shift = true : @in_shift = false
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

	private
	def set_author_dept_and_times
		@sticky.author = current_user
		@sticky.department = current_department
		@sticky.start = Time.now
		if params[:end_time_choice] == "indefinite"
			@sticky.end = nil
			@sticky.indefinite = true
		elsif params[:sticky][:end] == "day"
			@sticky.end = 1.day.from_now
		elsif params[:sticky][:end] == "week"
			@sticky.end = 1.week.from_now
		elsif params[:sticky][:end] == "month"
			@sticky.end = 1.month.from_now
		end
	end
end
