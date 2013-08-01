# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.destroy_all
Channel.destroy_all
Session.destroy_all

# User.create(name: 'User 1')
# User.create(name: 'User 2')

# Channel.create(name: 'Room 1')
# Channel.create(name: 'Room 2')

# Session.create(login: 5.minutes.ago, logout: 1.minute.ago, idle: 115, user: User.first, channels: [Channel.first])