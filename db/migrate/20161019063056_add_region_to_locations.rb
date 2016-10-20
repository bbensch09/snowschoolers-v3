class AddRegionToLocations < ActiveRecord::Migration
  def change
        add_column :locations, :region, :string
        add_column :locations, :state, :string
  end
end
