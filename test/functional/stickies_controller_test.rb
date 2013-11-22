require 'test_helper'

class StickiesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stickies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sticky" do
    assert_difference('Sticky.count') do
      post :create, sticky: { }
    end

    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should show sticky" do
    get :show, id: stickies(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: stickies(:one).to_param
    assert_response :success
  end

  test "should update sticky" do
    put :update, id: stickies(:one).to_param, sticky: { }
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should destroy sticky" do
    assert_difference('Sticky.count', -1) do
      delete :destroy, id: stickies(:one).to_param
    end

    assert_redirected_to stickies_path
  end
end
