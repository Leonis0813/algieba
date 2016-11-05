class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def check_user
    if session[:ticket]
      if login_user
        redirect_to_management_url
      else
        redirect_to_unless_login_url
      end
    else
      redirect_to_unless_login_url
    end
  end

  def check_client
    credential = request.headers['Authorization'].match(/Basic (.+)/)[1]
    application_id, application_key = Base64.strict_decode64(credential).split(':')
    raise Unauthorized.new unless Client.find_by(:application_id => application_id, :application_key => application_key)
  end

  def redirect_to_management_url
    session[:ticket] = Base64.strict_encode64("#{login_user[:user_id]}:#{login_user[:password]}")
    redirect_to :controller => 'accounts', :action => 'manage'
  end

  rescue_from BadRequest do |e|
    render :status => :bad_request, :json => e.errors
  end

  rescue_from Unauthorized do |e|
    head :unauthorized
  end

  rescue_from NotFound do |e|
    head :not_found
  end

  rescue_from InternalServerError do |e|
    head :internal_server_error
  end

  private

  def login_user
    ticket = Base64.strict_decode64(session[:ticket])
    user_id, password = ticket.split(':')
    User.find_by(:user_id => user_id, :password => password)
  end

  def redirect_to_unless_login_url
    redirect_to login_url unless request.path_info == login_path
  end
end
