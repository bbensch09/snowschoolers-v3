class AddGuestEmailToLesson < ActiveRecord::Migration[5.0]
  def change
    add_column :lessons, :guest_email, :string
  end
end
