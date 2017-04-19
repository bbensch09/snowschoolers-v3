class CreateProductCalendars < ActiveRecord::Migration[5.0]
  def change
    create_table :product_calendars do |t|
      t.integer :product_id
      t.integer :price
      t.date :date
      t.string :status
      t.timestamps
    end
  end
end
