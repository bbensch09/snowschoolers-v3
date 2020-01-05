class ChangeProductLengthToFloat < ActiveRecord::Migration[6.0]
  def change
  	change_column :products, :length, 'float USING CAST(length as float)'
  end
end
