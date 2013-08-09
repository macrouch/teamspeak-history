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
			logout, logout_time = logout_from_css(d.css('div.uhist_list_time'))

			# if they logged out more than a couple of days ago, don't do anything
			if logout_time

				# Find the user name
				user = user_from_css(d.css('div.uhist_list_nick_reg strong').first)

				# Find the channel name
				channel = channel_from_css(d.css('div.uhist_list_channel'))

				# Find the login time
				login_time = login_from_css(d.css('div.uhist_list_nick_reg span'), 
																		d.css('div.uhist_list_time_connect'), 
																		logout_time)

				# Find idle time in seconds "0D 00:41:24" -> 2484
				idle = idle_from_css(d.css('div.uhist_list_nick_reg span'))

				# Find the session, or create a new one
				previous_session = user.sessions.order("login desc").first
				session = nil
				if previous_session
					# if the previous session is the current session
					# sometimes the seconds would be off from my conversions. 
					# the quick solution is don't compare seconds since I don't care about them
					if previous_session.login.strftime('%Y-%m-%d %H:%M') == login_time.strftime('%Y-%m-%d %H:%M')
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

			end # end unless logout
		end # end userlist loop
	end

	def self.user_from_css(css)
		# Saw a name like "cool name <-See Me". The '<' character messed everything up.
		# Just in case we can split on 'Logintime:', and it will pull out only the actual name
		name = css.content.split('Logintime:')[0].strip	
		User.find_or_create_by(name: name)	
	end

	def self.channel_from_css(css)
		channel_name = css.inner_text.gsub(/\P{ASCII}/, '').strip
		Channel.find_or_create_by(name: channel_name)		
	end

	def self.login_from_css(css, time_css, logout)
		logout = logout.in_time_zone(1)
		today = DateTime.now.in_time_zone(1) # in +0100 (Germany)(Where tsviewer is located)
		login_time_ago = css.inner_text.split('Logintime: ')[1].split(',')[0]
		logged_in_time = login_time_ago.split(' ')[1].split(':')
		# login_days = logout.day - (logout - login_time_ago.split('D')[0].to_i.days).day
		# login_hours = logged_in_time[0]
		# login_minutes = logged_in_time[1]
		login_seconds = (login_time_ago.split('D')[0].to_i * (86400)) + 
											(logged_in_time[0].to_i * 3600)	+ 
											(logged_in_time[1].to_i * 60)	+ 
											(logged_in_time[2].to_i)

		login_days = logout.day - (logout - login_seconds.seconds).day
		login = time_css.inner_text
		time = login.split(' ')[1].split(':')
		((today.day - logout.day).days.ago - login_days.days + (time[0].to_i - today.hour).hours + 
			(time[1].to_i - today.minute).minutes + (0 - today.second).seconds).in_time_zone	
	end

	def self.logout_from_css(css)
		today = DateTime.now.in_time_zone(1) # in +0100 (Germany)(Where tsviewer is located)
		logout = css.inner_text.downcase
		time = logout.split(' ')[1].split(':')
		if logout.include?('online') || logout.include?('today')
			[logout, (today + (time[0].to_i - today.hour).hours + 
				(time[1].to_i - today.minute).minutes + (0 - today.second).seconds).in_time_zone]
		elsif logout.include?('yesterday')
			[logout, (today - 1.day + (time[0].to_i - today.hour).hours + 
				(time[1].to_i - today.minute).minutes + (0 - today.second).seconds).in_time_zone]
		else # if the session ended before 'yesterday', we don't care about it anymore
			[logout, nil]
		end		
	end

	def self.idle_from_css(css)
		idle = css.inner_text.split('Idletime: ')[1]
		# number of days * 86400
		# number of hours * 3600
		# number of minutes * 60
		time = idle.split(' ')[1].split(':')
		idle = (idle.split('D')[0].to_i * (86400)) + 
						(time[0].to_i * 3600)	+ 
						(time[1].to_i * 60)	+ 
						(time[2].to_i)		
	end

	def self.session_from_css(css)

	end

	protected

	def unique_login_per_user
		if user && user.sessions.where(login: login).size > 0 && new_record?
			errors.add(:login, "has to be unique per user")
		end
	end
end
