class Session < ActiveRecord::Base
	belongs_to :user
	has_and_belongs_to_many :channels

	validates :login, :logout, :idle, presence: true
end
