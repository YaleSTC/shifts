require 'test_helper'

class CalendarFeedsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:calendar_feeds)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create calendar_feed" do
    assert_difference('CalendarFeed.count') do
      post :create, calendar_feed: { }
    end

    assert_redirected_to calendar_feed_path(assigns(:calendar_feed))
  end

  test "should show calendar_feed" do
    get :show, id: calendar_feeds(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: calendar_feeds(:one).to_param
    assert_response :success
  end

  test "should update calendar_feed" do
    put :update, id: calendar_feeds(:one).to_param, calendar_feed: { }
    assert_redirected_to calendar_feed_path(assigns(:calendar_feed))
  end

  test "should destroy calendar_feed" do
    assert_difference('CalendarFeed.count', -1) do
      delete :destroy, id: calendar_feeds(:one).to_param
    end

    assert_redirected_to calendar_feeds_path
  end
end
