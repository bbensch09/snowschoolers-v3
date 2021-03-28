class AddUserAgentToTickets < ActiveRecord::Migration[6.0]
  def change
  		 add_column :tickets, :agent_id, :integer
  		 add_column :tickets, :agent_adjustment_amount, :float
  		 add_column :tickets, :agent_adjustment_memo, :string
  end
end
