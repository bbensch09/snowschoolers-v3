class Transaction < ActiveRecord::Base
  belongs_to :lesson
  belongs_to :ticket
  belongs_to :requester, class_name: 'User', foreign_key: 'requester_id'

  validates :tip_amount, presence: true

end
