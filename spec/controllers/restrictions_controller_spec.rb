require File.dirname(__FILE__) + '/../spec_helper'
 
describe RestrictionsController do
  fixtures :all
  render_views
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    get :show, id: Restriction.first
    response.should render_template(:show)
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "create action should render new template when model is invalid" do
    Restriction.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    Restriction.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(restriction_url(assigns[:restriction]))
  end
  
  it "edit action should render edit template" do
    get :edit, id: Restriction.first
    response.should render_template(:edit)
  end
  
  it "update action should render edit template when model is invalid" do
    Restriction.any_instance.stubs(:valid?).returns(false)
    put :update, id: Restriction.first
    response.should render_template(:edit)
  end
  
  it "update action should redirect when model is valid" do
    Restriction.any_instance.stubs(:valid?).returns(true)
    put :update, id: Restriction.first
    response.should redirect_to(restriction_url(assigns[:restriction]))
  end
  
  it "destroy action should destroy model and redirect to index action" do
    restriction = Restriction.first
    delete :destroy, id: restriction
    response.should redirect_to(restrictions_url)
    Restriction.exists?(restriction.id).should be_false
  end
end
