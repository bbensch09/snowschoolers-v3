class CreateApplicants < ActiveRecord::Migration[5.0]
  def change
    create_table :applicants do |t|
      t.integer :user_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number
      t.text :intro
      t.string :status
      t.string :city
      t.integer :age
      t.string :preferred_locations
      t.string :how_did_you_hear
      t.boolean :work_authorization

      t.timestamps
    end
  end
end
