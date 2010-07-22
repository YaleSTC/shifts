require 'test_helper'

class ShiftPreferencesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:shift_preferences)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create shift_preference" do
    assert_difference('ShiftPreference.count') do
      post :create, :shift_preference => { }
    end

    assert_redirected_to shift_preference_path(assigns(:shift_preference))
  end

  test "should show shift_preference" do
    get :show, :id => shift_preferences(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => shift_preferences(:one).to_param
    assert_response :success
  end

  test "should update shift_preference" do
    put :update, :id => shift_preferences(:one).to_param, :shift_preference => { }
    assert_redirected_to shift_preference_path(assigns(:shift_preference))
  end

  test "should destroy shift_preference" do
    assert_difference('ShiftPreference.count', -1) do
      delete :destroy, :id => shift_preferences(:one).to_param
    end

    assert_redirected_to shift_preferences_path
  end
end
