# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.

# UNCOMMENT CODE BELOW TO RESTORE ACTION CABLE

# class ConversationChannel < ApplicationCable::Channel
#   def subscribed
#     stream_from "conversation_channel"
#   end

#   def unsubscribed
#     # Any cleanup needed when channel is unsubscribed
#   end

#   def speak(data)
#     newMessage = Message.create(author_id: data['message']['message[author_id]'], conversation_id: data['message']["message[conversation_id]"], recipient_id: data['message']["message[recipient_id]"], unread: data['message']["message[unread]"] , content: data['message']['message[content]'])
#     ActionCable.server.broadcast "conversation_channel", message: newMessage
#   end
# end
