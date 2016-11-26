class Blog < ApplicationRecord

  has_attached_file :cover_photo, styles: { large: "400x400>", thumb: "80x80>" },  default_url: "https://s3.amazonaws.com/snowschoolers/cd-sillouhete.jpg",
        :storage => :s3,
        :bucket => 'snowschoolers'
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
  validates_attachment_content_type :cover_photo, content_type: /\Aimage\/.*\Z/

  def to_param
        [id, title.parameterize].join("-")
  end

  def time_since_written
  days_elapsed = ((Time.now - updated_at.to_time) / (60*60*24)).round
  hours_elapsed = ((Time.now - updated_at.to_time) / (60*60)).round
  minutes_elapsed = ((Time.now - updated_at.to_time) / (60)).round
    if minutes_elapsed < 60
      return "#{minutes_elapsed} minutes ago."
    elsif hours_elapsed < 24
      return "#{hours_elapsed} hours ago."
    else
      return "#{days_elapsed} days ago."
    end
  end

end
