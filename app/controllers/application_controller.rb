class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def check_user
    if session[:ticket]
      ticket = Base64.strict_decode64(session[:ticket])
      user_id, password = ticket.split(':')
      if User.find_by(:user_id => user_id, :password => password)
        logger.info ("Login_user: #{user_id}")
        redirect_unless '/'
      else
        redirect_unless login_path
      end
    else
      redirect_unless login_path
    end
  end

  def check_client
    credential = request.headers['Authorization'].match(/Basic (.+)/)[1]
    application_id, application_key = Base64.strict_decode64(credential).split(':')
    raise Unauthorized.new unless Client.find_by(:application_id => application_id, :application_key => application_key)
  end

  def redirect_to_management_url

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

  def redirect_unless(path)
    redirect_to path unless request.path_info == path
  end
end
