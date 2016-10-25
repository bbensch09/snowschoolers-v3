json.array!(@messages) do |message|
  json.extract! message, :id, :author_id, :conversation_id, :content, :unread, :recipient_id
  json.url message_url(message, format: :json)
end
