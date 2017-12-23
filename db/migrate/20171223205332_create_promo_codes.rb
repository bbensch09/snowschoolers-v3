class CreatePromoCodes < ActiveRecord::Migration[5.0]
  def change
    create_table :promo_codes do |t|
      t.string :promo_code
      t.string :status
      t.integer :redemptions
      t.string :description
      t.timestamps
    end
  end
end
