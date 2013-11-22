require File.dirname(__FILE__) + '/../spec_helper'
 
describe PayformItemSetsController do
  fixtures :all
  integrate_views
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    get :show, id: PayformItemSet.first
    response.should render_template(:show)
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "create action should render new template when model is invalid" do
    PayformItemSet.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    PayformItemSet.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(payform_item_set_url(assigns[:payform_item_set]))
  end
  
  it "edit action should render edit template" do
    get :edit, id: PayformItemSet.first
    response.should render_template(:edit)
  end
  
  it "update action should render edit template when model is invalid" do
    PayformItemSet.any_instance.stubs(:valid?).returns(false)
    put :update, id: PayformItemSet.first
    response.should render_template(:edit)
  end
  
  it "update action should redirect when model is valid" do
    PayformItemSet.any_instance.stubs(:valid?).returns(true)
    put :update, id: PayformItemSet.first
    response.should redirect_to(payform_item_set_url(assigns[:payform_item_set]))
  end
  
  it "destroy action should destroy model and redirect to index action" do
    payform_item_set = PayformItemSet.first
    delete :destroy, id: payform_item_set
    response.should redirect_to(payform_item_sets_url)
    PayformItemSet.exists?(payform_item_set.id).should be_false
  end
end
