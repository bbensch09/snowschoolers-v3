require 'twilio-ruby'

class TwilioController < ApplicationController
  include Webhookable

  after_filter :set_header

  skip_before_action :verify_authenticity_token

  def test_sms
    account_sid = ENV['TWILIO_SID']
    auth_token = ENV['TWILIO_AUTH']
    snow_schoolers_twilio_number = ENV['TWILIO_NUMBER']
    recipient = Instructor.first.phone_number
    @client = Twilio::REST::Client.new account_sid, auth_token
        @client.account.messages.create({
        :to => recipient,
        :from => "#{snow_schoolers_twilio_number}",
        :body => 'You have a test lesson request. Are you available? Reply "YES" to accept this lesson. Reply "NO" to dismiss.'
    })
    redirect_to root_path
  end

end
