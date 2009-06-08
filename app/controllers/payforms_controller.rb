class PayformsController < ApplicationController
  def index
    @payforms = Payform.find(:all)
  end

  def show
    @payform = Payform.find(params[:id])
  end

  def new
    redirect_to Payform.current(current_department, current_user)
  end

end

