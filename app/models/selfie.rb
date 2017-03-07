class Selfie < ApplicationRecord
	belongs_to :contestant
	belongs_to :location
	validates :location_id, :date, :social_network, presence: true

end
