require File.dirname(__FILE__) + '/../spec_helper'
 
describe PunchClocksController do
  fixtures :all
  render_views
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    get :show, id: PunchClock.first
    response.should render_template(:show)
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "create action should render new template when model is invalid" do
    PunchClock.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    PunchClock.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(punch_clock_url(assigns[:punch_clock]))
  end
  
  it "edit action should render edit template" do
    get :edit, id: PunchClock.first
    response.should render_template(:edit)
  end
  
  it "update action should render edit template when model is invalid" do
    PunchClock.any_instance.stubs(:valid?).returns(false)
    put :update, id: PunchClock.first
    response.should render_template(:edit)
  end
  
  it "update action should redirect when model is valid" do
    PunchClock.any_instance.stubs(:valid?).returns(true)
    put :update, id: PunchClock.first
    response.should redirect_to(punch_clock_url(assigns[:punch_clock]))
  end
  
  it "destroy action should destroy model and redirect to index action" do
    punch_clock = PunchClock.first
    delete :destroy, id: punch_clock
    response.should redirect_to(punch_clocks_url)
    PunchClock.exists?(punch_clock.id).should be_false
  end
end
