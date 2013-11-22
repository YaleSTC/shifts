require 'test_helper'

class NoticesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:notices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create notice" do
    assert_difference('Notice.count') do
      post :create, notice: { }
    end

    assert_redirected_to notice_path(assigns(:notice))
  end

  test "should show notice" do
    get :show, id: notices(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: notices(:one).to_param
    assert_response :success
  end

  test "should update notice" do
    put :update, id: notices(:one).to_param, notice: { }
    assert_redirected_to notice_path(assigns(:notice))
  end

  test "should destroy notice" do
    assert_difference('Notice.count', -1) do
      delete :destroy, id: notices(:one).to_param
    end

    assert_redirected_to notices_path
  end
end
