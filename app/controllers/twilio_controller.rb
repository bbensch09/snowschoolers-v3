require 'twilio-ruby'

class TwilioController < ApplicationController
  include Webhookable

  after_filter :set_header

  skip_before_action :verify_authenticity_token

  def voice
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'Hey there. Congrats on integrating Twilio into your Rails 4 app.', :voice => 'alice'
         r.Play 'http://linode.rabasa.com/cantina.mp3'
    end

    render_twiml(response)
  end

  def test_sms
    account_sid = ENV['TWILIO_SID']
    auth_token = ENV['TWILIO_AUTH']
    @client = Twilio::REST::Client.new account_sid, auth_token
    @message = @client.account.messages.get("MM800f449d0399ed014aae2bcc0cc2f2ec")
    puts "-------messages retrieved?-----------"
    puts @message.body
  end

end
