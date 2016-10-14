class AddPartnerStatusToUsers < ActiveRecord::Migration
  def change
      add_column :users, :user_type, :string
      add_column :users, :location_id, :integer
      remove_column :users, :verified_instructor, :string
  end
end
