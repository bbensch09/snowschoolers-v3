class Message < ActiveRecord::Base
  belongs_to :conversation
  # Should be perform later, but is not working. Temp fix perform now
  after_create_commit { MessageBroadcastJob.perform_now self }

def send_sms_to_instructor(conversation)
      account_sid = ENV['TWILIO_SID']
      auth_token = ENV['TWILIO_AUTH']
      snow_schoolers_twilio_number = ENV['TWILIO_NUMBER']
      recipient = conversation.instructor.phone_number
      body = "#{conversation.instructor.first_name}, #{conversation.requester.name} has started a conversation with you. You can read their message and reply by visiting: #{ENV['HOST_DOMAIN']}/my_conversations."
      @client = Twilio::REST::Client.new account_sid, auth_token
          @client.account.messages.create({
          :to => recipient,
          :from => "#{snow_schoolers_twilio_number}",
          :body => body
      })
    puts "!!!! SMS sent to instructor"
  end

end
