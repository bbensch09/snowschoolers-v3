class AddLiftTicketStatusToLessons < ActiveRecord::Migration[5.0]
  def change
      add_column :lessons, :lift_ticket_status, :string
  end
end
