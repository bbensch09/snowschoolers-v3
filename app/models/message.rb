class Message < ActiveRecord::Base
  belongs_to :conversation
  # Should be perform later, but is not working. Temp fix perform now
  after_create_commit { MessageBroadcastJob.perform_now self }
end
