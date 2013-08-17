require 'tzinfo'

class UsersController < ApplicationController
  def index
    @users = User.all.order("name")
    @user = nil
    @sessions = []
    @session = nil
    @channels = []

    @user = User.find(params[:user_id]) if params[:user_id]
    @sessions = Session.where(user: @user).order("login desc") if @user

    @session = @user.sessions.where(id: params[:session_id]).first if params[:session_id]
    @channels = @session.channels if @session

    if cookies[:time_zone]
      time_zone = TZInfo::Timezone.get(cookies[:time_zone])
      current = time_zone.current_period 
      @offset = current.utc_total_offset
    else
      @offset = 0
    end
  end
end
