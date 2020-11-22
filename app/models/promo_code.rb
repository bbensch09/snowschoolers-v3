class PromoCode < ApplicationRecord
	has_many :lessons
	has_many :tickets
end
