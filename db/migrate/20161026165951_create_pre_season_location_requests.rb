class CreatePreSeasonLocationRequests < ActiveRecord::Migration
  def change
    create_table :pre_season_location_requests do |t|
      t.string :name

      t.timestamps
    end
  end
end
