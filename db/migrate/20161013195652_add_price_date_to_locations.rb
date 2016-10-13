class AddPriceDateToLocations < ActiveRecord::Migration
  def change
          add_column :locations, :partner_status, :string
          add_column :locations, :calendar_status, :string
  end
end
