class AddParticipantsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :participants do |t|
      t.references :ticket
      t.string :name
      t.string :age_range
      t.string :gender
      t.string :booking_history
      t.string :experience
      t.string :relationship_to_requester
    end
  end
end
