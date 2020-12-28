class AddRetailProductsToTickets < ActiveRecord::Migration[6.0]
  def change
  		 add_column :tickets, :sleds_purchased, :integer
  		 add_column :tickets, :free_participants_redeemed, :integer
  		 add_column :tickets, :retail_item_name, :string
  		 add_column :tickets, :retail_item_quantity, :integer
  		 add_column :tickets, :retail_item_price, :float
  end
end
