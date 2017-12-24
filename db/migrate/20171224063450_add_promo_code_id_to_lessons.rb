class AddPromoCodeIdToLessons < ActiveRecord::Migration[5.0]
  def change
	    add_column :lessons, :promo_code_id, :integer
  end
end
