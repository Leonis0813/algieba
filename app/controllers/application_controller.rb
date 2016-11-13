class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def check_user
    if cookies[:algieba]
      user_id, password = parse_cookie
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
    if cookies[:algieba]
      user_id, password = parse_cookie
      return if User.find_by(:user_id => user_id, :password => password)
    end
    raise BadRequest.new('absent_header') unless request.headers['Authorization']
    credential = request.headers['Authorization'].match(/Basic (.+)/)[1]
    application_id, application_key = Base64.strict_decode64(credential).split(':')
    raise Unauthorized.new unless Client.find_by(:application_id => application_id, :application_key => application_key)
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

  def parse_cookie
    Base64.strict_decode64(cookies[:algieba]).split(':')
  end

  def redirect_unless(path)
    redirect_to path unless request.path_info == path
  end
end
