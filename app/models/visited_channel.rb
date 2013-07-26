class VisitedChannel < ActiveRecord::Base
	belongs_to :channel
	belongs_to :session
end
