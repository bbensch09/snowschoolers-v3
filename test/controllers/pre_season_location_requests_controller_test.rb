require 'test_helper'

class PreSeasonLocationRequestsControllerTest < ActionController::TestCase
  setup do
    @pre_season_location_request = pre_season_location_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pre_season_location_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pre_season_location_request" do
    assert_difference('PreSeasonLocationRequest.count') do
      post :create, pre_season_location_request: { name: @pre_season_location_request.name }
    end

    assert_redirected_to pre_season_location_request_path(assigns(:pre_season_location_request))
  end

  test "should show pre_season_location_request" do
    get :show, id: @pre_season_location_request
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @pre_season_location_request
    assert_response :success
  end

  test "should update pre_season_location_request" do
    patch :update, id: @pre_season_location_request, pre_season_location_request: { name: @pre_season_location_request.name }
    assert_redirected_to pre_season_location_request_path(assigns(:pre_season_location_request))
  end

  test "should destroy pre_season_location_request" do
    assert_difference('PreSeasonLocationRequest.count', -1) do
      delete :destroy, id: @pre_season_location_request
    end

    assert_redirected_to pre_season_location_requests_path
  end
end
