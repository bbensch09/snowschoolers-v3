class AddAdminPriceAdjustmentToLessons < ActiveRecord::Migration[5.0]
  def change
  	add_column :lessons, :admin_price_adjustment, :decimal
  end
end
