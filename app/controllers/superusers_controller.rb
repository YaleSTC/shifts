class SuperusersController < ApplicationController
  before_filter :require_superuser

  def index
    @superusers = User.superusers
  end

  def add
    @new_su = User.find_by_login(params[:new_su_login])
    if @new_su
      if @new_su.is_superuser?
        flash[:notice] = "No change. <b>#{@new_su.name}</b> is already a superuser."
      else
        @new_su.update_attribute(:superuser,true)
        flash[:notice] = "<b>#{@new_su.name}</b> is now a superuser."
      end
      redirect_to(superusers_path)
    else
      flash[:notice] = "<b>#{params[:new_su_login]}</b> is an invalid login. Please enter a valid login name."
      render :action => 'index'
    end
  end

  #TODO: add error checking here.  Not really necessary because only superusers can access this page
  def remove
    @su_list = User.find(params[:remove_su_ids])
    if User.superusers.length == @su_list.count
      flash[:error] = "You are not allowed to remove the only superuser in the application."
    else
      @su_list.each do |su|
        su.update_attribute(:superuser, false)
      end
      su_names = @su_list.collect { |u| "<b>#{u.name}</b>" }
      flash[:notice] = "Removed superuser privilege from #{su_names.to_sentence}"
    end
    redirect_to(superusers_path)
  end
end

