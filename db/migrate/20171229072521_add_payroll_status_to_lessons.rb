class AddPayrollStatusToLessons < ActiveRecord::Migration[5.0]
  def change
  	add_column :lessons, :payment_status, :string
  	add_column :lessons, :payment_method, :string
  	add_column :lessons, :payment_date, :string
  end
end
