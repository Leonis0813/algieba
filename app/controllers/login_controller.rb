class LoginController < ApplicationController
  before_filter :check_user, :except => [:authenticate_user]

  def authenticate_user
    login_user = User.find_by(user_param)
    if login_user
      cookies[:algieba] = Base64.strict_encode64("#{login_user[:user_id]}:#{login_user[:password]}")
      redirect_to :controller => 'payments', :action => 'index'
    else
      redirect_to login_url
    end
  end

  private

  def user_param
    params.permit(:user_id, :password)
  end
end
