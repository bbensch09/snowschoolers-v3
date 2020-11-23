class AddCheckInToTickets < ActiveRecord::Migration[6.0]
  def change
	 add_column :tickets, :check_in_status, :string
  end
end
