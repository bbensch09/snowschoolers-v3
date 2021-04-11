class AddParticipantTypeSnowplaySleddingSpectator < ActiveRecord::Migration[6.0]
  def change
    add_column :participants, :guest_type, :string
  end
end
