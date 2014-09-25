require File.dirname(__FILE__) + '/../spec_helper'
 
describe ReportItemsController do
  fixtures :all
  integrate_views
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    get :show, id: ReportItem.first
    response.should render_template(:show)
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "create action should render new template when model is invalid" do
    ReportItem.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    ReportItem.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(report_item_url(assigns[:report_item]))
  end
  
  it "edit action should render edit template" do
    get :edit, id: ReportItem.first
    response.should render_template(:edit)
  end
  
  it "update action should render edit template when model is invalid" do
    ReportItem.any_instance.stubs(:valid?).returns(false)
    put :update, id: ReportItem.first
    response.should render_template(:edit)
  end
  
  it "update action should redirect when model is valid" do
    ReportItem.any_instance.stubs(:valid?).returns(true)
    put :update, id: ReportItem.first
    response.should redirect_to(report_item_url(assigns[:report_item]))
  end
  
  it "destroy action should destroy model and redirect to index action" do
    report_item = ReportItem.first
    delete :destroy, id: report_item
    response.should redirect_to(report_items_url)
    ReportItem.exists?(report_item.id).should be_false
  end
end
