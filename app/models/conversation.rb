class Conversation < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :requester, class_name: "User", foreign_key: 'requester_id'
  has_many :messages

end
