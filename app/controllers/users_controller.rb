require 'tzinfo'

class UsersController < ApplicationController
  def index
    @users = User.all.order("name")
    @user = nil
    @sessions = []
    @session = nil
    @channels = []
    @month = params[:month] || 0

    @user = User.find(params[:user_id]) if params[:user_id]
    @sessions = Session.by_user_and_months_ago(@user, @month.to_i) if @user

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

  def select_user
    set_user

    respond_to do |format|
      format.js
    end
  end

  def select_month
    set_user
    set_month
    set_offset

    respond_to do |format|
      format.js
    end
  end

  def select_session
    set_user
    set_month
    set_session

    respond_to do |format|
      format.js
    end    
  end

  protected

  def set_user
    @user = User.find(params[:user_id]) if params[:user_id]
  end

  def set_month    
    @month = params[:month] || 0
    @sessions = Session.by_user_and_months_ago(@user, @month.to_i) if @user    
  end

  def set_session
    @session = @user.sessions.where(id: params[:session_id]).first if params[:session_id]
    @channels = @session.channels if @session    
  end

  def set_offset
    if cookies[:time_zone]
      time_zone = TZInfo::Timezone.get(cookies[:time_zone])
      current = time_zone.current_period 
      @offset = current.utc_total_offset
    else
      @offset = 0
    end
    
  end

end
