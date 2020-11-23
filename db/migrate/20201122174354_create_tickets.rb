class CreateTickets < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets do |t|
      t.integer :requester_id
      t.string :deposit_status
      t.integer :lesson_time_id
      t.string :activity
      t.string :requester_name
      t.string :requested_location
      t.string :phone_number
      t.string :state
      t.string :actual_start_time
      t.boolean :terms_accepted
      t.string :guest_email
      t.string :how_did_you_hear
      t.integer :num_days
      t.decimal :booking_order_value
      t.boolean :is_gift_voucher
      t.string :gift_recipient_email
      t.string :gift_recipient_name
      t.integer :product_id
      t.decimal :admin_price_adjustment
      t.integer :promo_code_id
      t.string :planned_start_time
      t.string :payment_status
      t.string :payment_method
      t.string :payment_date
      t.text :additional_info
      t.string :ticket_type
      t.string :street_address
      t.string :city
      t.string :state_code
      t.string :zip_code
      t.string :drivers_license
      t.boolean :skip_validations
      t.string :administrator_notes
      t.boolean :multi_product_order
      t.boolean :refund_issued

      t.timestamps
    end
  end
end
