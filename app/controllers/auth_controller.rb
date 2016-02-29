class AuthController < ApplicationController
  skip_authorization_check

  def login
    user = User.active.find_by_username(params[:username])
    return head :bad_request if user.blank? or not user.authenticate(params[:password])
    session[:user_id]     = user.id
    session[:submissions] = {}
    session[:forms]       = {}
    expose user_id: user.id, session_id: session.id
  end

  def logout
    session.delete(:user_id)
    head :no_content
  end
end
