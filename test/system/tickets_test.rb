require "application_system_test_case"

class TicketsTest < ApplicationSystemTestCase
  setup do
    @ticket = tickets(:one)
  end

  test "visiting the index" do
    visit tickets_url
    assert_selector "h1", text: "Tickets"
  end

  test "creating a Ticket" do
    visit tickets_url
    click_on "New Ticket"

    fill_in "Activity", with: @ticket.activity
    fill_in "Actual start time", with: @ticket.actual_start_time
    fill_in "Additional info", with: @ticket.additional_info
    fill_in "Admin price adjustment", with: @ticket.admin_price_adjustment
    fill_in "Administrator notes", with: @ticket.administrator_notes
    fill_in "Booking order value", with: @ticket.booking_order_value
    fill_in "City", with: @ticket.city
    fill_in "Deposit status", with: @ticket.deposit_status
    fill_in "Drivers license", with: @ticket.drivers_license
    fill_in "Gift recipient email", with: @ticket.gift_recipient_email
    fill_in "Gift recipient name", with: @ticket.gift_recipient_name
    fill_in "Guest email", with: @ticket.guest_email
    fill_in "How did you hear", with: @ticket.how_did_you_hear
    check "Is gift voucher" if @ticket.is_gift_voucher
    fill_in "Lesson time", with: @ticket.lesson_time_id
    check "Multi product order" if @ticket.multi_product_order
    fill_in "Num days", with: @ticket.num_days
    fill_in "Payment date", with: @ticket.payment_date
    fill_in "Payment method", with: @ticket.payment_method
    fill_in "Payment status", with: @ticket.payment_status
    fill_in "Phone number", with: @ticket.phone_number
    fill_in "Planned start time", with: @ticket.planned_start_time
    fill_in "Product", with: @ticket.product_id
    fill_in "Promo code", with: @ticket.promo_code_id
    check "Refund issued" if @ticket.refund_issued
    fill_in "Requested location", with: @ticket.requested_location
    fill_in "Requester", with: @ticket.requester_id
    check "Skip validations" if @ticket.skip_validations
    fill_in "State", with: @ticket.state
    fill_in "State code", with: @ticket.state_code
    fill_in "Street address", with: @ticket.street_address
    check "Terms accepted" if @ticket.terms_accepted
    fill_in "Ticket type", with: @ticket.ticket_type
    fill_in "Zip code", with: @ticket.zip_code
    click_on "Create Ticket"

    assert_text "Ticket was successfully created"
    click_on "Back"
  end

  test "updating a Ticket" do
    visit tickets_url
    click_on "Edit", match: :first

    fill_in "Activity", with: @ticket.activity
    fill_in "Actual start time", with: @ticket.actual_start_time
    fill_in "Additional info", with: @ticket.additional_info
    fill_in "Admin price adjustment", with: @ticket.admin_price_adjustment
    fill_in "Administrator notes", with: @ticket.administrator_notes
    fill_in "Booking order value", with: @ticket.booking_order_value
    fill_in "City", with: @ticket.city
    fill_in "Deposit status", with: @ticket.deposit_status
    fill_in "Drivers license", with: @ticket.drivers_license
    fill_in "Gift recipient email", with: @ticket.gift_recipient_email
    fill_in "Gift recipient name", with: @ticket.gift_recipient_name
    fill_in "Guest email", with: @ticket.guest_email
    fill_in "How did you hear", with: @ticket.how_did_you_hear
    check "Is gift voucher" if @ticket.is_gift_voucher
    fill_in "Lesson time", with: @ticket.lesson_time_id
    check "Multi product order" if @ticket.multi_product_order
    fill_in "Num days", with: @ticket.num_days
    fill_in "Payment date", with: @ticket.payment_date
    fill_in "Payment method", with: @ticket.payment_method
    fill_in "Payment status", with: @ticket.payment_status
    fill_in "Phone number", with: @ticket.phone_number
    fill_in "Planned start time", with: @ticket.planned_start_time
    fill_in "Product", with: @ticket.product_id
    fill_in "Promo code", with: @ticket.promo_code_id
    check "Refund issued" if @ticket.refund_issued
    fill_in "Requested location", with: @ticket.requested_location
    fill_in "Requester", with: @ticket.requester_id
    check "Skip validations" if @ticket.skip_validations
    fill_in "State", with: @ticket.state
    fill_in "State code", with: @ticket.state_code
    fill_in "Street address", with: @ticket.street_address
    check "Terms accepted" if @ticket.terms_accepted
    fill_in "Ticket type", with: @ticket.ticket_type
    fill_in "Zip code", with: @ticket.zip_code
    click_on "Update Ticket"

    assert_text "Ticket was successfully updated"
    click_on "Back"
  end

  test "destroying a Ticket" do
    visit tickets_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Ticket was successfully destroyed"
  end
end
