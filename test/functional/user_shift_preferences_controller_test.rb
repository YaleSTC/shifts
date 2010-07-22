require 'test_helper'

class UserShiftPreferencesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_shift_preferences)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_shift_preference" do
    assert_difference('UserShiftPreference.count') do
      post :create, :user_shift_preference => { }
    end

    assert_redirected_to user_shift_preference_path(assigns(:user_shift_preference))
  end

  test "should show user_shift_preference" do
    get :show, :id => user_shift_preferences(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => user_shift_preferences(:one).to_param
    assert_response :success
  end

  test "should update user_shift_preference" do
    put :update, :id => user_shift_preferences(:one).to_param, :user_shift_preference => { }
    assert_redirected_to user_shift_preference_path(assigns(:user_shift_preference))
  end

  test "should destroy user_shift_preference" do
    assert_difference('UserShiftPreference.count', -1) do
      delete :destroy, :id => user_shift_preferences(:one).to_param
    end

    assert_redirected_to user_shift_preferences_path
  end
end
