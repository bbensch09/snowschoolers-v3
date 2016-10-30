class AddProductTypeColumnsToProducts < ActiveRecord::Migration
  def change
      add_column :products, :product_type, :string #lesson, lift ticket, rental, lift & lesson package, lift + lesson + rental package
      add_column :products, :is_lesson, :boolean, :default => false
      add_column :products, :is_private_lesson, :boolean, :default => false
      add_column :products, :is_group_lesson, :boolean, :default => false
      add_column :products, :is_lift_ticket, :boolean, :default => false
      add_column :products, :is_rental, :boolean, :default => false
      add_column :products, :is_lift_rental_package, :boolean, :default => false
      add_column :products, :is_lift_lesson_package, :boolean, :default => false
      add_column :products, :is_lift_lesson_rental_package, :boolean, :default => false
      add_column :products, :is_multi_day, :boolean, :default => false
      add_column :products, :age_type, :string
      change_column :products, :price, :float

      # Expand data about resorts
      add_column :locations, :vertical_feet, :integer
      add_column :locations, :base_elevation, :integer
      add_column :locations, :peak_elevation, :integer
      add_column :locations, :skiable_acres, :integer
      add_column :locations, :average_snowfall, :integer
      add_column :locations, :lift_count, :integer
      add_column :locations, :address, :string
      add_column :locations, :night_skiing, :boolean

  end
end
