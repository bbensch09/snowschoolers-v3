class AddOpenStatusToLocations < ActiveRecord::Migration[5.0]
  def change
  	add_column :locations, :closing_date, :date
  end
end
