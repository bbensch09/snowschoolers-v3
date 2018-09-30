class JoinTableRentalsResources < ActiveRecord::Migration[5.0]
  def change
  	create_table :rentals do |t|
      t.integer :lesson_id
      t.integer :student_id
      t.integer :resource_id
      t.string :resource_type
      t.date :rental_date
      t.string :status
      t.string :other
      t.timestamps
    end

    create_table :resources do |t|
      t.string :resource_type
      t.string :gb_identifier
      t.string :manufacturer
      t.string :board_model
      t.string :binding_model
      t.boolean :is_boot
      t.string :boot_age
      t.string :boot_size
      t.string :boot_size_raw
      t.string :board_size
      t.string :status
      t.string :ss_unique_identifier
      t.string :non_unique_identifier
      t.boolean :walk_in_only
      t.timestamps
  	end

    create_join_table :rentals, :resources do |t|
    end
  end
end
