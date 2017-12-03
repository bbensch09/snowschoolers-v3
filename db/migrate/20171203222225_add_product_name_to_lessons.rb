class AddProductNameToLessons < ActiveRecord::Migration[5.0]
  def change
  	  	add_column :lessons, :product_name, :string
  end
end
