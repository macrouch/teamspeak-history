require 'spec_helper'

describe Session do
	def user_css(name)
		Nokogiri::HTML("<strong>#{name}</strong>")
	end

	def channel_css(name)
		Nokogiri::HTML("<div class='uhist_list_channel'><img src='http://static.tsviewer.com/images/teamspeak3/standard/16x16_channel_open.png' alt='' width='10' height='10'> &nbsp;#{name}</div>")
	end

	def login_css(total_time, time)
		[Nokogiri::HTML("<span>Logintime: #{total_time}, Idletime: 0D 01:29:05</span>"),
		Nokogiri::HTML("<div class='uhist_list_time_connect'><strong>Today</strong>, #{time}</div>")]
	end

	def logout_css(day, time)
		Nokogiri::HTML("<div class='uhist_list_time'><strong><font color='#c80007'>#{day}</font></strong>, #{time}</div>")
	end

	def idle_css(time)
		Nokogiri::HTML("<span>Logintime: 0D 00:29:38, Idletime: #{time}</span>")
	end

	it "is valid with valid attributes" do
		Fabricate(:session).should be_valid
	end

	it { should validate_presence_of :login }
	it { should validate_presence_of :idle }
	it { should belong_to :user }

	it "selects user correctly" do
		user = Session.user_from_css(user_css("User 1"))
		user.should be_valid
	end

	it "selects channel correctly" do
		channel = Session.channel_from_css(channel_css("Channel 1"))
		channel.should be_valid
	end

	it "converts idle time correctly" do
		idle = Session.idle_from_css(idle_css("0D 00:41:24"))
		idle.should eq(2484)
	end

	it "converts times correctly"	do
		time = DateTime.now.in_time_zone(1)
		today = time.strftime("%Y-%m-%d")
		yesterday = (time - 1.days).strftime("%Y-%m-%d")
		two_days_ago = (time - 2.days).strftime("%Y-%m-%d")
		three_days_ago = (time - 3.days).strftime("%Y-%m-%d")
		four_days_ago = (time - 4.days).strftime("%Y-%m-%d")

		logout = (time + (23 - time.hour).hours + (0 - time.minute).minutes + (0 - time.second).seconds).in_time_zone
		css = login_css("0D 01:00:00", "22:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{today} 20:00:00 UTC")
		css = login_css("1D 01:00:00", "22:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{yesterday} 20:00:00 UTC")
		css = login_css("2D 01:00:00", "22:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{two_days_ago} 20:00:00 UTC")
		css = login_css("3D 01:00:00", "22:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{three_days_ago} 20:00:00 UTC")

		logout = (time + (2 - time.hour).hours + (0 - time.minute).minutes + (0 - time.second).seconds).in_time_zone
		css = login_css("0D 01:00:00", "01:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{yesterday} 23:00:00 UTC")
		css = login_css("1D 01:00:00", "01:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{two_days_ago} 23:00:00 UTC")
		css = login_css("2D 01:00:00", "01:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{three_days_ago} 23:00:00 UTC")
		css = login_css("3D 01:00:00", "01:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{four_days_ago} 23:00:00 UTC")

		logout = (time + (2 - time.hour).hours + (0 - time.minute).minutes + (0 - time.second).seconds).in_time_zone
		css = login_css("0D 01:00:00", "00:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{yesterday} 22:00:00 UTC")
		css = login_css("1D 01:00:00", "00:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{two_days_ago} 22:00:00 UTC")
		css = login_css("2D 01:00:00", "00:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{three_days_ago} 22:00:00 UTC")
		css = login_css("3D 01:00:00", "00:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{four_days_ago} 22:00:00 UTC")

		logout = (time + (2 - time.hour).hours + (0 - time.minute).minutes + (0 - time.second).seconds).in_time_zone
		css = login_css("0D 03:00:00", "23:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{yesterday} 21:00:00 UTC")
		css = login_css("1D 03:00:00", "23:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{two_days_ago} 21:00:00 UTC")
		css = login_css("2D 03:00:00", "23:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{three_days_ago} 21:00:00 UTC")
		css = login_css("3D 03:00:00", "23:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{four_days_ago} 21:00:00 UTC")

		logout = (time + (3 - time.hour).hours + (0 - time.minute).minutes + (0 - time.second).seconds).in_time_zone
		css = login_css("0D 01:00:00", "02:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{today} 00:00:00 UTC")
		css = login_css("1D 01:00:00", "02:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{yesterday} 00:00:00 UTC")
		css = login_css("2D 01:00:00", "02:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{two_days_ago} 00:00:00 UTC")
		css = login_css("3D 01:00:00", "02:00")
		login = Session.login_from_css(css[0], css[1], logout)
		login.to_s.should eq("#{three_days_ago} 00:00:00 UTC")
	end

	it "converts logout correctly"	do
		time = DateTime.now.in_time_zone(1)
		today = time.strftime("%Y-%m-%d")
		tomorrow = (time + 1.day).strftime("%Y-%m-%d")
		yesterday = (time - 1.days).strftime("%Y-%m-%d")
		two_days_ago = (time - 2.days).strftime("%Y-%m-%d")

		logout, logout_time = Session.logout_from_css(logout_css("ONLINE","23:00"))
		logout_time.to_s.should eq("#{today} 21:00:00 UTC")
		logout, logout_time = Session.logout_from_css(logout_css("Today","23:00"))
		logout_time.to_s.should eq("#{today} 21:00:00 UTC")
		logout, logout_time = Session.logout_from_css(logout_css("Yesterday","23:00"))
		logout_time.to_s.should eq("#{yesterday} 21:00:00 UTC")

		logout, logout_time = Session.logout_from_css(logout_css("ONLINE","00:00"))
		logout_time.to_s.should eq("#{yesterday} 22:00:00 UTC")
		logout, logout_time = Session.logout_from_css(logout_css("Today","00:00"))
		logout_time.to_s.should eq("#{yesterday} 22:00:00 UTC")
		logout, logout_time = Session.logout_from_css(logout_css("Yesterday","00:00"))
		logout_time.to_s.should eq("#{two_days_ago} 22:00:00 UTC")

		logout, logout_time = Session.logout_from_css(logout_css("ONLINE","00:30"))
		logout_time.to_s.should eq("#{yesterday} 22:30:00 UTC")
		logout, logout_time = Session.logout_from_css(logout_css("Today","00:30"))
		logout_time.to_s.should eq("#{yesterday} 22:30:00 UTC")
		logout, logout_time = Session.logout_from_css(logout_css("Yesterday","00:30"))
		logout_time.to_s.should eq("#{two_days_ago} 22:30:00 UTC")

		logout, logout_time = Session.logout_from_css(logout_css("ONLINE","01:00"))
		logout_time.to_s.should eq("#{yesterday} 23:00:00 UTC")
		logout, logout_time = Session.logout_from_css(logout_css("Today","01:00"))
		logout_time.to_s.should eq("#{yesterday} 23:00:00 UTC")
		logout, logout_time = Session.logout_from_css(logout_css("Yesterday","01:00"))
		logout_time.to_s.should eq("#{two_days_ago} 23:00:00 UTC")

		logout, logout_time = Session.logout_from_css(logout_css("ONLINE","02:00"))
		logout_time.to_s.should eq("#{today} 00:00:00 UTC")
		logout, logout_time = Session.logout_from_css(logout_css("Today","02:00"))
		logout_time.to_s.should eq("#{today} 00:00:00 UTC")
		logout, logout_time = Session.logout_from_css(logout_css("Yesterday","02:00"))
		logout_time.to_s.should eq("#{yesterday} 00:00:00 UTC")
	end

	it "should enforce unique logins per user" do
		user = User.create(name: "User 1")
		channel = Channel.create(name: "Channel 1")

		time = DateTime.now.in_time_zone(1)
		logout = (time + (7 - time.hour).hours + (12 - time.minute).minutes + (0 - time.second).seconds).in_time_zone
		css = login_css("0D 01:00:00", "06:37")
		login = Session.login_from_css(css[0], css[1], logout)
		idle = 42

		session = Session.create(user: user, login: login, logout: logout, idle: idle)
		session.should be_valid
		Session.count.should eq(1)


		session2 = Session.create(user: user, login: login, logout: logout, idle: idle)
		session2.should_not be_valid
		session2.errors[:login].should include("has to be unique per user")
		Session.count.should eq(1)
	end
end