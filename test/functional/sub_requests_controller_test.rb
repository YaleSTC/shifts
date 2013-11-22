require 'test_helper'

class SubRequestsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sub_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sub_request" do
    assert_difference('SubRequest.count') do
      post :create, sub_request: { }
    end

    assert_redirected_to sub_request_path(assigns(:sub_request))
  end

  test "should show sub_request" do
    get :show, id: sub_requests(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: sub_requests(:one).to_param
    assert_response :success
  end

  test "should update sub_request" do
    put :update, id: sub_requests(:one).to_param, sub_request: { }
    assert_redirected_to sub_request_path(assigns(:sub_request))
  end

  test "should destroy sub_request" do
    assert_difference('SubRequest.count', -1) do
      delete :destroy, id: sub_requests(:one).to_param
    end

    assert_redirected_to sub_requests_path
  end
end
