class AddTicketIdToStudents < ActiveRecord::Migration[6.0]
  def change
  	  	add_column :students, :ticket_id, :integer
  end
end
