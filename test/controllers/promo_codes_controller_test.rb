require 'test_helper'

class PromoCodesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @promo_code = promo_codes(:one)
  end

  test "should get index" do
    get promo_codes_url
    assert_response :success
  end

  test "should get new" do
    get new_promo_code_url
    assert_response :success
  end

  test "should create promo_code" do
    assert_difference('PromoCode.count') do
      post promo_codes_url, params: { promo_code: { description: @promo_code.description, promo_code: @promo_code.promo_code, redemptions: @promo_code.redemptions, status: @promo_code.status } }
    end

    assert_redirected_to promo_code_url(PromoCode.last)
  end

  test "should show promo_code" do
    get promo_code_url(@promo_code)
    assert_response :success
  end

  test "should get edit" do
    get edit_promo_code_url(@promo_code)
    assert_response :success
  end

  test "should update promo_code" do
    patch promo_code_url(@promo_code), params: { promo_code: { description: @promo_code.description, promo_code: @promo_code.promo_code, redemptions: @promo_code.redemptions, status: @promo_code.status } }
    assert_redirected_to promo_code_url(@promo_code)
  end

  test "should destroy promo_code" do
    assert_difference('PromoCode.count', -1) do
      delete promo_code_url(@promo_code)
    end

    assert_redirected_to promo_codes_url
  end
end
