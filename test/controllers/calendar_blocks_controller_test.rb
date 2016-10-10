require 'test_helper'

class CalendarBlocksControllerTest < ActionController::TestCase
  setup do
    @calendar_block = calendar_blocks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:calendar_blocks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create calendar_block" do
    assert_difference('CalendarBlock.count') do
      post :create, calendar_block: { instructor_id: @calendar_block.instructor_id, lesson_time_id: @calendar_block.lesson_time_id, status: @calendar_block.status }
    end

    assert_redirected_to calendar_block_path(assigns(:calendar_block))
  end

  test "should show calendar_block" do
    get :show, id: @calendar_block
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @calendar_block
    assert_response :success
  end

  test "should update calendar_block" do
    patch :update, id: @calendar_block, calendar_block: { instructor_id: @calendar_block.instructor_id, lesson_time_id: @calendar_block.lesson_time_id, status: @calendar_block.status }
    assert_redirected_to calendar_block_path(assigns(:calendar_block))
  end

  test "should destroy calendar_block" do
    assert_difference('CalendarBlock.count', -1) do
      delete :destroy, id: @calendar_block
    end

    assert_redirected_to calendar_blocks_path
  end
end
