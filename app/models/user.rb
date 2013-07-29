class User < ActiveRecord::Base
	has_many :sessions

	validates :name, presence: true
end
