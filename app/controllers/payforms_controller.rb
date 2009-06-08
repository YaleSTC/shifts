class PayformsController < ApplicationController
  def index
    @payforms = Payform.all
  end

  def show
    if params[:id]
      @payform = Payform.find(params[:id])
    else
      redirect_to Payform.current(current_department, current_user)
    end
  end

end

