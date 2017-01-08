class AddVoucherAndPackageElementsToLessons < ActiveRecord::Migration[5.0]
  def change
      add_column :lessons, :is_gift_voucher, :boolean, :default => false
      add_column :lessons, :includes_lift_or_rental_package, :boolean, :default => false
      add_column :lessons, :package_info, :text
      add_column :lessons, :gift_recipient_email, :string
      add_column :lessons, :gift_recipient_name, :string
  end
end
