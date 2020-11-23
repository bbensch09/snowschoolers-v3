require 'test_helper'

class TicketsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ticket = tickets(:one)
  end

  test "should get index" do
    get tickets_url
    assert_response :success
  end

  test "should get new" do
    get new_ticket_url
    assert_response :success
  end

  test "should create ticket" do
    assert_difference('Ticket.count') do
      post tickets_url, params: { ticket: { activity: @ticket.activity, actual_start_time: @ticket.actual_start_time, additional_info: @ticket.additional_info, admin_price_adjustment: @ticket.admin_price_adjustment, administrator_notes: @ticket.administrator_notes, booking_order_value: @ticket.booking_order_value, city: @ticket.city, deposit_status: @ticket.deposit_status, drivers_license: @ticket.drivers_license, gift_recipient_email: @ticket.gift_recipient_email, gift_recipient_name: @ticket.gift_recipient_name, guest_email: @ticket.guest_email, how_did_you_hear: @ticket.how_did_you_hear, is_gift_voucher: @ticket.is_gift_voucher, lesson_time_id: @ticket.lesson_time_id, multi_product_order: @ticket.multi_product_order, num_days: @ticket.num_days, payment_date: @ticket.payment_date, payment_method: @ticket.payment_method, payment_status: @ticket.payment_status, phone_number: @ticket.phone_number, planned_start_time: @ticket.planned_start_time, product_id: @ticket.product_id, promo_code_id: @ticket.promo_code_id, refund_issued: @ticket.refund_issued, requested_location: @ticket.requested_location, requester_id: @ticket.requester_id, skip_validations: @ticket.skip_validations, state: @ticket.state, state_code: @ticket.state_code, street_address: @ticket.street_address, terms_accepted: @ticket.terms_accepted, ticket_type: @ticket.ticket_type, zip_code: @ticket.zip_code } }
    end

    assert_redirected_to ticket_url(Ticket.last)
  end

  test "should show ticket" do
    get ticket_url(@ticket)
    assert_response :success
  end

  test "should get edit" do
    get edit_ticket_url(@ticket)
    assert_response :success
  end

  test "should update ticket" do
    patch ticket_url(@ticket), params: { ticket: { activity: @ticket.activity, actual_start_time: @ticket.actual_start_time, additional_info: @ticket.additional_info, admin_price_adjustment: @ticket.admin_price_adjustment, administrator_notes: @ticket.administrator_notes, booking_order_value: @ticket.booking_order_value, city: @ticket.city, deposit_status: @ticket.deposit_status, drivers_license: @ticket.drivers_license, gift_recipient_email: @ticket.gift_recipient_email, gift_recipient_name: @ticket.gift_recipient_name, guest_email: @ticket.guest_email, how_did_you_hear: @ticket.how_did_you_hear, is_gift_voucher: @ticket.is_gift_voucher, lesson_time_id: @ticket.lesson_time_id, multi_product_order: @ticket.multi_product_order, num_days: @ticket.num_days, payment_date: @ticket.payment_date, payment_method: @ticket.payment_method, payment_status: @ticket.payment_status, phone_number: @ticket.phone_number, planned_start_time: @ticket.planned_start_time, product_id: @ticket.product_id, promo_code_id: @ticket.promo_code_id, refund_issued: @ticket.refund_issued, requested_location: @ticket.requested_location, requester_id: @ticket.requester_id, skip_validations: @ticket.skip_validations, state: @ticket.state, state_code: @ticket.state_code, street_address: @ticket.street_address, terms_accepted: @ticket.terms_accepted, ticket_type: @ticket.ticket_type, zip_code: @ticket.zip_code } }
    assert_redirected_to ticket_url(@ticket)
  end

  test "should destroy ticket" do
    assert_difference('Ticket.count', -1) do
      delete ticket_url(@ticket)
    end

    assert_redirected_to tickets_url
  end
end
