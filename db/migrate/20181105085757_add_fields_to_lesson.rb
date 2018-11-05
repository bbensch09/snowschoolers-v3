class AddFieldsToLesson < ActiveRecord::Migration[5.0]
  def change
  	add_column :lessons, :lodging_guest, :boolean
  	add_column :lessons, :lodging_reservation_id, :string
  	add_column :lessons, :street_address, :string
  	add_column :lessons, :city, :string
  	add_column :lessons, :state_code, :string
  	add_column :lessons, :zip_code, :string
  	add_column :lessons, :drivers_license, :string
  end
end
