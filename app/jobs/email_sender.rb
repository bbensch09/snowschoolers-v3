class EmailSender
  @queue = :snowschoolers_email_queue

  def self.perform(params)
  	puts "!!! params are: #{params}"
    #code to send out emails
    LessonMailer.test_email.deliver
  end
end