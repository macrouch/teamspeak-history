class Session < ActiveRecord::Base
	belongs_to :user
	has_and_belongs_to_many :channels

	validates :login, :idle, presence: true

	def closed?
		logout != nil
	end
end
