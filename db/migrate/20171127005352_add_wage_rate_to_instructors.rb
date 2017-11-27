class AddWageRateToInstructors < ActiveRecord::Migration[5.0]
  def change
  	add_column :instructors, :base_rate, :float
  end
end
