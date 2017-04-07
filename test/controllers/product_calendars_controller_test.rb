require 'test_helper'

class ProductCalendarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product_calendar = product_calendars(:one)
  end

  test "should get index" do
    get product_calendars_url
    assert_response :success
  end

  test "should get new" do
    get new_product_calendar_url
    assert_response :success
  end

  test "should create product_calendar" do
    assert_difference('ProductCalendar.count') do
      post product_calendars_url, params: { product_calendar: { date: @product_calendar.date, price: @product_calendar.price, product_id: @product_calendar.product_id, status: @product_calendar.status } }
    end

    assert_redirected_to product_calendar_url(ProductCalendar.last)
  end

  test "should show product_calendar" do
    get product_calendar_url(@product_calendar)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_calendar_url(@product_calendar)
    assert_response :success
  end

  test "should update product_calendar" do
    patch product_calendar_url(@product_calendar), params: { product_calendar: { date: @product_calendar.date, price: @product_calendar.price, product_id: @product_calendar.product_id, status: @product_calendar.status } }
    assert_redirected_to product_calendar_url(@product_calendar)
  end

  test "should destroy product_calendar" do
    assert_difference('ProductCalendar.count', -1) do
      delete product_calendar_url(@product_calendar)
    end

    assert_redirected_to product_calendars_url
  end
end
