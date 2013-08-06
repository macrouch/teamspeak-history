require 'nokogiri'
require 'open-uri'

namespace :ts do
	task :import => :environment do
		Session.import
	end # end task :import
end # end namespace
