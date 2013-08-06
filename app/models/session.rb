class Session < ActiveRecord::Base
	belongs_to :user
	has_and_belongs_to_many :channels

	validates :login, :idle, presence: true

	validate :unique_login_per_user

	def closed?
		logout != nil
	end

	def self.import
		server_id = ENV["TS_SERVER_ID"]
		doc = Nokogiri::HTML(open("http://www.tsviewer.com/index.php?page=userhistory&ID=#{server_id}&site=1&limit=1000"))
		doc.css('ul.userlist li').each do |d| # each row in table

			# Find the logout time
			logout = d.css('div.uhist_list_time').inner_text.downcase
			logout_time = nil
			old = false
			today = DateTime.now(0100) # Now in +0100 (Germany)(Where tsviewer is located)
			time = logout.split(' ')[1].split(':')
			if logout.include?('online') || logout.include?('today')
				logout_time = DateTime.new(today.year, today.month, today.day, time[0].to_i, time[1].to_i, 00, '+0100').in_time_zone
			elsif logout.include?('yesterday')
				logout_time = DateTime.new(today.year, today.month, 1.day.ago.day, time[0].to_i, time[1].to_i, 00, '+0100').in_time_zone
			else # if the session ended before 'yesterday', we don't care about it anymore
				old = true
			end

			# if they logged out more than a couple of days ago, don't do anything
			unless old

				# Find the user name
				# Saw a name like "cool name <-See Me". The '<' character messed everything up.
				# Just in case we can split on 'Logintime:', and it will pull out only the actual name
				name = d.css('div.uhist_list_nick_reg strong').first.content.split('Logintime:')[0].strip
				user = User.find_or_create_by(name: name)

				# Find the channel name
				channel_name = d.css('div.uhist_list_channel').inner_text.gsub(/\P{ASCII}/, '').strip
				channel = Channel.find_or_create_by(name: channel_name)

				# Find the login time
				login_ago = d.css('div.uhist_list_nick_reg span').inner_text.split('Logintime: ')[1].split(',')[0]
				login_days_ago = login_ago.split('D')[0].to_i
				login = d.css('div.uhist_list_time_connect').inner_text
				time = login.split(' ')[1].split(':')
				login_time = (DateTime.new(today.year, today.month, today.day, time[0].to_i, time[1].to_i, 00, '+0100') - login_days_ago.days).in_time_zone

				# Find idle time in seconds "0D 00:41:24" -> 2484
				idle = d.css('div.uhist_list_nick_reg span').inner_text.split('Idletime: ')[1]
				# number of days * 86400
				# number of hours * 3600
				# number of minutes * 60
				time = idle.split(' ')[1].split(':')
				idle = (idle.split('D')[0].to_i * (86400)) + 
								(time[0].to_i * 3600)	+ 
								(time[1].to_i * 60)	+ 
								(time[2].to_i)

				# Find the session, or create a new one
				previous_session = user.sessions.order("login desc").first
				session = nil
				if previous_session
					# if the previous session is the current session
					if user.name == "DG| bentbarrel | 2LT"
						puts "previous_session == #{previous_session.login.strftime('%Y-%m-%d %H:%M:%S')}"
						puts "login_time ==       #{login_time.strftime('%Y-%m-%d %H:%M:%S')}"
					end
					if previous_session.login.strftime('%Y-%m-%d %H:%M:%S') == login_time.strftime('%Y-%m-%d %H:%M:%S')
						session = previous_session
					else
						# if previous session is not current session
						# close previous session and start a new session
						unless previous_session.closed?
							previous_session.logout = login_time
							previous_session.save
						end
						session = Session.new(login: login_time, user: user)
					end
				else # no previous sessions
					session = Session.new(login: login_time, user: user)
				end
				session.idle = idle

				# dont do anything if the session was already closed
				unless session.closed?
					if logout.include?('online')
						session.logout = nil
					else
						session.logout = logout_time
					end
					session.save
				end

				# add the channel to the session unless it is already there
				session.channels << channel unless session.channels.include?(channel)

			end # end unless old
		end # end userlist loop
	end

	protected

	def unique_login_per_user
		if user && user.sessions.where(login: login).size > 0 && new_record?
			errors.add(:login, "has to be unique per user")
		end
	end
end
