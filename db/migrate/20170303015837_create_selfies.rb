class CreateSelfies < ActiveRecord::Migration[5.0]
  def change
    create_table :selfies do |t|
      t.string :link
      t.integer :location_id
      t.integer :contestant_id
      t.date :date
      t.string :social_network

      t.timestamps
    end
  end
end
