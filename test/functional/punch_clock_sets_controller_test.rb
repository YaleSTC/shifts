require 'test_helper'

class PunchClockSetsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:punch_clock_sets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create punch_clock_set" do
    assert_difference('PunchClockSet.count') do
      post :create, punch_clock_set: { }
    end

    assert_redirected_to punch_clock_set_path(assigns(:punch_clock_set))
  end

  test "should show punch_clock_set" do
    get :show, id: punch_clock_sets(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: punch_clock_sets(:one).to_param
    assert_response :success
  end

  test "should update punch_clock_set" do
    put :update, id: punch_clock_sets(:one).to_param, punch_clock_set: { }
    assert_redirected_to punch_clock_set_path(assigns(:punch_clock_set))
  end

  test "should destroy punch_clock_set" do
    assert_difference('PunchClockSet.count', -1) do
      delete :destroy, id: punch_clock_sets(:one).to_param
    end

    assert_redirected_to punch_clock_sets_path
  end
end
