class PayformsController < ApplicationController
  def index
    redirect_to Payform.current(current_department, current_user)
  end

  def show
    @payform = Payform.find(params[:id])
  end

end

