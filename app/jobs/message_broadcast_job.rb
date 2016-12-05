class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    ActionCable.server.broadcast 'conversation_channel', {my_message: render_my_message(message), their_message: render_their_message(message), author_id: message.author_id}
  end

  def after_perform(message)
    p "Message job has been created."
  end

  private

  def render_my_message(message)
    ApplicationController.renderer.render(partial: 'messages/current_user_message', locals: { message: message , user: User.find(message.author_id)})
  end

  def render_their_message(message)
    ApplicationController.renderer.render(partial: 'messages/other_user_message', locals: { message: message , user: User.find(message.author_id)})
  end
end
