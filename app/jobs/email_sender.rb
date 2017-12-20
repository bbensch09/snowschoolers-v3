class EmailSender
  @queue = :snowschoolers_email_queue

  def self.perform(params)
    #code to send out emails
    LessonMailer.notify_admin_lesson_full_form_updated(Lesson.last, 'bbensch@gmail.com').deliver  #_in(1.minute)
  end
end